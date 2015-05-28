<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:uml="http://www.omg.org/spec/UML/20110701" 
	xmlns:xmi="http://www.omg.org/spec/XMI/20110701" xmlns:ddifunc="ddi:functions"
    exclude-result-prefixes="ddifunc"
    version="2.0">

    <!-- imports -->
    <xsl:import href="../../util/src/support.xsl"/>

    <!-- options -->
    <xsl:output method="xml" indent="yes"/>
	
	<xsl:template match="xmi:XMI">
		<xmi:XMI xmi:version="2.4.1">
			<xsl:attribute name="xmi:version">
				<xsl:value-of select="xmi:version"/>
			</xsl:attribute>
			<xsl:copy-of select="xmi:Documentation"/>
			<xsl:apply-templates select="uml:Model"/>
			<xsl:apply-templates select="xmi:Extension"/>
		</xmi:XMI>
	</xsl:template>
	
	<xsl:template match="uml:Model">
		<uml:Model>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="packagedElement[1]" mode="library"/>
			<xsl:copy-of select="packagedElement[2]"/>
		</uml:Model>
	</xsl:template>
	
	<xsl:template match="packagedElement" mode="library">
		<packagedElement>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="packagedElement" mode="package"/>
		</packagedElement>
	</xsl:template>
	
	<xsl:template match="packagedElement" mode="package">
		<packagedElement>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="packagedElement[@xmi:type='uml:Class' and not(@isAbstract='true')]" mode="class"/>
			<xsl:copy-of select="packagedElement[@xmi:type='uml:Enumeration' or @xmi:type='uml:DataType']"/>
		</packagedElement>
	</xsl:template>
	
	<xsl:template match="packagedElement" mode="class">
		<packagedElement>
			<xsl:copy-of select="@*"/>
			<xsl:variable name="parentClass" select="generalization/@general"/>
			<xsl:apply-templates select="//packagedElement[@name=$parentClass]" mode="parentClass">
				<xsl:with-param name="className" select="@name"/>
			</xsl:apply-templates>
			<xsl:copy-of select="ownedAttribute"/>
		</packagedElement>
		<!-- associations -->
	</xsl:template>
	
	<xsl:template match="packagedElement" mode="parentClass">
		<xsl:param name="className"/>
		<xsl:variable name="parentClass" select="generalization/@general"/>
		<xsl:apply-templates select="//packagedElement[@name=$parentClass]" mode="parentClass">
			<xsl:with-param name="className" select="$className"/>
		</xsl:apply-templates>
		<xsl:copy-of select="ownedAttribute"/>
		<!-- associations -->
	</xsl:template>
	
	<xsl:template match="xmi:Extension">
		<xmi:Extension>
			<xsl:copy-of select="@*"/>
			<elements>
				<xsl:copy-of select="elements/element[@xmi:type='uml:Package']"/>
				<!-- all needed stuff -->
			</elements>
		</xmi:Extension>
	</xsl:template>
	
</xsl:stylesheet>