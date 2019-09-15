-- MySQL dump 10.13  Distrib 5.1.73, for redhat-linux-gnu (x86_64)
--
-- Host: localhost    Database: portabilidad
-- ------------------------------------------------------
-- Server version	5.1.73

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `abcdp_numeros_portados`
--

DROP TABLE IF EXISTS `abcdp_numeros_portados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `abcdp_numeros_portados` (
  `phone_number` varchar(9) NOT NULL,
  `codigo_area` int(11) NOT NULL DEFAULT '0',
  `nrn_donante` int(11) DEFAULT NULL,
  `nrn_receptor` int(11) DEFAULT NULL,
  `fecha_portado` datetime DEFAULT NULL,
  `fecha_update` datetime DEFAULT NULL,
  PRIMARY KEY (`codigo_area`,`phone_number`),
  KEY `idx_numero_portado` (`phone_number`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `abcdp_total`
--

DROP TABLE IF EXISTS `abcdp_total`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `abcdp_total` (
  `phone_number` varchar(9) NOT NULL,
  `codigo_area` int(11) NOT NULL DEFAULT '0',
  `nrn_donante` int(11) DEFAULT NULL,
  `nrn_receptor` int(11) DEFAULT NULL,
  `fecha_portado` datetime DEFAULT NULL,
  `fecha_update` datetime DEFAULT NULL,
  PRIMARY KEY (`codigo_area`,`phone_number`),
  KEY `idx_numero_portado` (`phone_number`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `abdcp_numeros_portados`
--

DROP TABLE IF EXISTS `abdcp_numeros_portados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `abdcp_numeros_portados` (
  `phone_number` varchar(9) NOT NULL,
  `codigo_area` int(11) NOT NULL DEFAULT '0',
  `nrn_donante` int(11) DEFAULT NULL,
  `nrn_receptor` int(11) DEFAULT NULL,
  `fecha_portado` datetime DEFAULT NULL,
  `fecha_update` datetime DEFAULT NULL,
  PRIMARY KEY (`codigo_area`,`phone_number`),
  KEY `idx_numero_portado` (`phone_number`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `control_portabilidad`
--

DROP TABLE IF EXISTS `control_portabilidad`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `control_portabilidad` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `process_seq` char(8) NOT NULL,
  `process_date` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=360 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `his_numeros_portados`
--

DROP TABLE IF EXISTS `his_numeros_portados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `his_numeros_portados` (
  `codigo_area` varchar(2) NOT NULL,
  `phone_number` varchar(9) NOT NULL,
  `routing_donante` varchar(2) NOT NULL,
  `routing_receptor` varchar(2) NOT NULL,
  `fecha_alta` datetime DEFAULT NULL,
  `fecha_baja` datetime DEFAULT NULL,
  PRIMARY KEY (`codigo_area`,`phone_number`,`routing_donante`,`routing_receptor`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `numeros_portados`
--

DROP TABLE IF EXISTS `numeros_portados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `numeros_portados` (
  `phone_number` varchar(9) NOT NULL,
  `codigo_area` int(11) NOT NULL DEFAULT '0',
  `nrn_donante` int(11) DEFAULT NULL,
  `nrn_receptor` int(11) DEFAULT NULL,
  `fecha_alta` datetime NOT NULL,
  PRIMARY KEY (`codigo_area`,`phone_number`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `operadores`
--

DROP TABLE IF EXISTS `operadores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `operadores` (
  `codigo` varchar(3) NOT NULL,
  `operador` varchar(55) NOT NULL,
  PRIMARY KEY (`codigo`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plan_numeracion`
--

DROP TABLE IF EXISTS `plan_numeracion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plan_numeracion` (
  `prefijo` varchar(11) NOT NULL,
  `codigo_area` int(11) DEFAULT NULL,
  `operador` varchar(3) DEFAULT NULL,
  `nrn` int(11) DEFAULT NULL,
  `fecha_ingreso` datetime DEFAULT NULL,
  PRIMARY KEY (`prefijo`),
  KEY `idx_plan_numeracion` (`prefijo`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `routing_numbers`
--

DROP TABLE IF EXISTS `routing_numbers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `routing_numbers` (
  `nrn` int(11) NOT NULL DEFAULT '0',
  `operador` varchar(3) DEFAULT NULL,
  PRIMARY KEY (`nrn`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-09-15 11:18:43
