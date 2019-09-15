#!/usr/bin/perl

use English;
use IO::Handle;
use DBI;
use Config::Auto;
use DateTime::Format::DBI;
use DateTime::Format::Strptime;
use File::Find::Rule;
use Text::Template;
use Mail::Sender;
use Net::SFTP::Foreign;

##
## Inicio de definiciones de funciones
##-----------------------------------------------------------------------------------------------------------------

## Funcion que procesa los archivos secuenciales
sub procesar_seq {
	my ($proc_seq) = @_;
	
	## Archivo a procesar
	my $date_now = DateTime->now(time_zone=>'America/Lima')->strftime('%m/%d/%Y %H:%M:%S');
	print "INFO $date_now - Procesando archivo secuencial: $proc_seq ...\n";
	my $file_input = $input_path.'/NumeracionesPortadas_'.$proc_seq;
	my $file_output = $output_path.'/'.$proc_seq.'.csv';
	my $file_diff = $output_path.'/'.$proc_seq.'.diff';
	my $file_temp = $output_path.'/'.$proc_seq.'.temp';
	my $file_last = $output_path.'/last.csv';
	
	if (!(-e $file_input)) {
		# Nos conectamos via sftp y descargamos los archivos
		$date_now = DateTime->now(time_zone=>'America/Lima')->strftime('%m/%d/%Y %H:%M:%S');
		print "INFO $date_now - Descargando el archivo secuencial via sftp: $proc_seq ...\n";
	
		my $remote = '/dailyfiles/'.substr($proc_seq, 0, 6).'/NumeracionesPortadas_'.$proc_seq.'.gz';
		my $local = $input_path.'/NumeracionesPortadas_'.$proc_seq.'.gz';
		#print "remote: $remote - local: $local\n";
		
		my $sftp = Net::SFTP::Foreign->new($sftp_srv, user => $sftp_user, password => $sftp_pass);
		$sftp->error and die "Something bad happened: " . $sftp->error;
		$sftp->get($remote, $local);
		
		my $cmd = 'gunzip '.$local;
		`$cmd`;
	}
	
	if (-e $file_input) {
		## Procesamos el archivo
		open(INPUT, $file_input) or die "No se puede abrir el archivo '$file_input' $!";
		open(OUTPUT, '>', $file_output) or die "No se puede abrir el archivo '$file_output' $!";
		my $i = 0;
		while (my $row = <INPUT>) {
			if ((!($row =~ m/EOF/ )) && ($i > 0)) {
				#print "$row";
				
				my $phone_number = substr($row, 20, 9);
				$phone_number =~ s/^\s+|\s+$//g;
				my $codigo_area;
				if ($phone_number =~ m/^9/i) {
					$codigo_area = '9';
				} elsif ($phone_number =~ m/^1/i) {
					$codigo_area = '1';
				} else {
					$codigo_area = substr($phone_number, 1, 2);
				}
				my $nrn_receptor = substr($row, 0, 2);
				my $nrn_donor = substr($row, 45, 2);
				my $fecha_portado = substr($row, 29, 8);
				
				my @fields = ($phone_number, $codigo_area, $nrn_receptor, $nrn_donor, $fecha_portado);
				my $str_fields = join "\t", @fields, "\n";
				#print "$str_fields";
				print OUTPUT $str_fields;
				#print "phone_number: $phone_number - codigo_area: $codigo_area - nrn_donor: $nrn_donor - nrn_receptor: $nrn_receptor - fecha_portado: $fecha_portado\n";
			}
			$i++;
		}    
		close(INPUT);
		close(OUTPUT);   
		
		## Generamos los archivos diff
		$cmd = 'sort '.$file_last.' '.$file_output.' | uniq -u > '.$file_temp;
		`$cmd`;
		$cmd = 'cat '.$file_temp.' | awk \'{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5}\' | uniq > '.$file_diff;
		`$cmd`;
		$cmd = 'rm -f '.$file_temp;
		`$cmd`;
		
		$cmd = "wc -l ".$file_diff." | cut -d ' ' -f 1";
		my $nro_numeros = `$cmd`;
		$nro_numeros =~ s/\n//;
		if ($nro_numeros > 0) {
			## actualizamos la base de datos con la información del diff
			open(DIFF, $file_diff) or die "No se puede abrir el archivo '$file_diff' $!";
			$dbh->{PrintError} = 0;
			while ($row = <DIFF>) {
				($phone_number, $codigo_area, $nrn_receptor, $nrn_donor, $fecha_portado) = split "\t", $row;
				$fecha_portado =~ s/\n//g;
				my $query = "insert into abdcp_numeros_portados (phone_number, codigo_area, nrn_donante, nrn_receptor, fecha_portado, fecha_update) ";
				$query = $query."values ('".$phone_number."', '".$codigo_area."', '".$nrn_donor."', '".$nrn_receptor."', '".$fecha_portado."', current_timestamp)";
				
				#print "$query\n";
				$sth = $dbh->prepare($query);
				$sth->execute();
				
				if ($sth->err) {
					#print "ERROR MARCO\n";
					# realizamos un update
					$query = "update abdcp_numeros_portados set nrn_donante = '".$nrn_donor."', nrn_receptor = '".$nrn_receptor."', fecha_portado = '".$fecha_portado."', fecha_update = current_timestamp ";
					$query = $query."where phone_number = '".$phone_number."' and codigo_area = '".$codigo_area."'";
					#print "$query\n";
					$sth = $dbh->prepare($query);
					$sth->execute();
				}
				$sth->finish;
			}
			close(DIFF);
			$dbh->{PrintError} = 1;
		}
		
		$date_now = DateTime->now(time_zone=>'America/Lima')->strftime('%m/%d/%Y %H:%M:%S');
		print "INFO $date_now - Base de datos actualizada archivo secuencial: $proc_seq ...\n";
	    
	    # Actualizamos la tabla control_portabilidad
	    $query = "insert into control_portabilidad (process_seq, process_date) values ('".$proc_seq."', current_timestamp)";
	    $sth = $dbh->prepare($query);
	    $sth->execute();
	    $sth->finish;
	    
	    # Actualizamos el archivo file_last
	    $cmd = 'cp '.$file_output.' '.$file_last;
	    `$cmd`;
	} else {
		# No existe archivo via sftp a procesar
		$date_now = DateTime->now(time_zone=>'America/Lima')->strftime('%m/%d/%Y %H:%M:%S');
		print "INFO $date_now - No se pudo descargar via sftp archivo secuencial: $proc_seq ...\n";
	}
}

## Funcion que obtiene una lista con los valores de secuencia de proceso (tabla control_portabilidad)
sub get_list_process_seq {
	my ($last_seq) = @_;
	
	my $year = substr($last_seq, 0, 4);
	my $month = substr($last_seq, 4, 2);
	my $day = substr($last_seq, 6, 2);
	my ($st, @dates);
	
	my $dt_ant = DateTime->new(year=>$year, month=>$month, day=>$day, time_zone=>'America/Lima');
	my $dt_now = DateTime->now(time_zone=>'America/Lima');

	$dt_ant = $dt_ant->add(days => 1);
	while ($dt_ant <= $dt_now) {
		$st = $dt_ant->strftime('%Y%m%d');
		push(@dates, $st);
		$dt_ant = $dt_ant->add(days => 1);
	}
	
	return @dates;
}

## Funcion de envio de correos
sub enviar_mail {
	my ($mail_type, $mail_text) = @_;
	
	my $date_now = DateTime->now(time_zone=>'America/Lima')->strftime('%m/%d/%Y %H:%M:%S');
    my $mail_detail = "$mail_type $date_now - $mail_text";
    print "$mail_detail";
    
    ##
    ## Enviando mails
    my $mail_date = `date`;
    my $mail_central = 'Reporte de Proceso de Portabilidad';
    my $mail_file = DateTime->now(time_zone=>'America/Lima')->strftime('%Y%m%d_%H%M%S');

    ## Email Full
    my $template = Text::Template->new(SOURCE => $mail_tmpl) or die $!;
    my %vars = ( mail_date => $mail_date,
                mail_central => $mail_central,
                mail_detail => $mail_detail, );
    my $mail_body = $template->fill_in(HASH => \%vars);

    my $cmd = 'mkdir -p '.$home.'/log/mail';
    `$cmd`;
    my $mail_file_full = $home.'/log/mail/'.$mail_file.'.mail';
    open EMAIL_FULL_FILE, ">$mail_file_full" or die $!;
    print EMAIL_FULL_FILE $mail_body;
    close EMAIL_FULL_FILE;
   
    # Sending email
    $mail_sender->MailMsg({ to => "$mail_inbox", subject => "$mail_type - Proceso Portabilidad", msg  => $mail_body });
     
    # Logging email
    $date_now = DateTime->now(time_zone=>'America/Lima')->strftime('%m/%d/%Y %H:%M:%S');
    print "INFO $date_now - Sending email $mail_type : $mail_file_full\n";
}

##
## Fin de definiciones de funciones
##-----------------------------------------------------------------------------------------------------------------

$home = '/usr/local/gilat';
$conf = $home.'/etc/numera_portax.conf';
$fpid = $home.'/var/numera_portax.pid';
$mail_tmpl = $home.'/etc/mail_numera_portax.tmpl';

##
## Parametros iniciales de configuracion

# Remove Mail::Sender logo feces from mail header
$Mail::Sender::NO_X_MAILER = 1;
$mail_sender = new Mail::Sender { smtp => '172.20.201.201', from => 'Portabilidad <rccopa@gilatla.com>' };

# Cantidad de dias desde la fecha actual
$ndays = 10;
$days_ago = time() - $ndays * 86400;

##
## Leyendo archivo de configuracion
 
$date_now = DateTime->now(time_zone=>'America/Lima')->strftime('%m/%d/%Y %H:%M:%S');
print "INFO $date_now - Leyendo archivo de configuracion $conf ...\n";
$vector = Config::Auto::parse($conf);

$key_cfg = 'general';
$input_path = $vector->{$key_cfg}->{input_path};
$output_path = $vector->{$key_cfg}->{output_path};
$mail_inbox = $vector->{$key_cfg}->{mail_inbox};

$key_cfg = 'sftp';
$sftp_srv = $vector->{$key_cfg}->{srv};
$sftp_user = $vector->{$key_cfg}->{user};
$sftp_pass = $vector->{$key_cfg}->{pass};

##
## Verificamos que solo haya un proceso siendo ejecutado a la vez

if (-e $fpid) {
	$mail_type = "ERROR";
	$mail_text = "Proceso en ejecucion, ya existe el archivo $fpid \n";
	enviar_mail($mail_type, $mail_text);
   	exit;
}

##
## Creando archivo de proceso
`touch $fpid`;
`echo $PID > $fpid`;

##
## Inicio de programa principal
##-----------------------------------------------------------------------------------------------------------------

##
## Iniciando conexion de base de datos
$key_cdr = 'db_mysql';

$date_now = DateTime->now(time_zone=>'America/Lima')->strftime('%m/%d/%Y %H:%M:%S');
print "INFO $date_now - Iniciando conectividad con $key_cdr ...\n";
$srv  = $vector->{$key_cdr}->{srv};
$db   = $vector->{$key_cdr}->{db} || $key_cdr;
$user = $vector->{$key_cdr}->{user};
$pass = $vector->{$key_cdr}->{pass};
$url = 'DBI:mysql:database='.$db.':host='.$srv;

$dbh = DBI->connect($url, $user, $pass);
if ($dbh) {
   print "WARN $date_now - Conectividad $key_cdr OK!\n";
} else {
   print "ERROR $date_now - No hay conectividad $key_cdr!\n";
   die;
}

##
## Validamos los archivos a procesar en la tabla de control (control_portabilidad)
$query = "select COALESCE(max(process_seq), DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '%Y%m%d')) from control_portabilidad";
$sth = $dbh->prepare($query);
$sth->execute();
$data = $sth->fetch;
$rst = $data->[0];
$sth->finish;

#print "resultado: $rst\n";
@vect_dates = get_list_process_seq($rst);
for (@vect_dates) {
    procesar_seq($_);
}

$vect_cnt = @vect_dates;
if ($vect_cnt > 0) {
	$mail_type = "INFO";
	$mail_text = "Finalizado el proceso de carga de numeros de portabilidad \n";
} else {
	$mail_type = "INFO";
	$mail_text = "No hay nada que procesar \n";
}
enviar_mail($mail_type, $mail_text);

##
## Fin de programa principal
##-----------------------------------------------------------------------------------------------------------------

##
## Eliminado archivo de proceso
`rm -f $fpid`;
