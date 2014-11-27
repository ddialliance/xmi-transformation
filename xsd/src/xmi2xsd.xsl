<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:uml="http://schema.omg.org/spec/UML/2.1"
    xmlns:xmi="http://schema.omg.org/spec/XMI/2.1" xmlns:ddifunc="ddi:functions"
    xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="ddifunc uml xmi"
    version="2.0">

    <!-- imports -->
    <xsl:import href="../../util/src/support.xsl"/>

    <!-- options -->
    <xsl:output method="xml" indent="yes"/>
	
	<!-- params -->
	<xsl:param name="filepath" select="'file:///C:/Work/output/'"/>
	
    <!-- variables -->
    <xsl:variable name="properties" select="document('xsd-properties.xml')"/>
	<xsl:variable name="stylesheetVersion">2.0.0</xsl:variable>

    <xsl:template match="xmi:XMI">
		<xs:schema version="1.0" elementFormDefault="qualified" attributeFormDefault="unqualified">
			<xsl:for-each select="$properties/SchemaCreationProperties/PackageNamespaces/Namespace">
				<xsl:namespace name="{@prefix}" select="concat('ddi:',lower-case(@name),':4_0')"/>
			</xsl:for-each>
			<xsl:comment>
				<xsl:text>This file was created by xmi2xsd version </xsl:text>
				<xsl:value-of select="$stylesheetVersion"/>
			</xsl:comment>
			<xsl:for-each select="$properties/SchemaCreationProperties/PackageNamespaces/Namespace">
				<xs:import>
					<xsl:attribute name="schemaLocation">
						<xsl:value-of select="@location"/>
					</xsl:attribute>
					<xsl:attribute name="namespace">
						<xsl:value-of select="concat('ddi:',lower-case(@name),':4_0')"/>
					</xsl:attribute>
				</xs:import>
			</xsl:for-each>
		</xs:schema>
		<xsl:apply-templates select="//packagedElement[@name='Packages']/packagedElement[@xmi:type='uml:Package']"
			mode="package"/>
		<xsl:apply-templates select="//packagedElement[@name='Functional Views']/packagedElement[@xmi:type='uml:Package']"
			mode="view"/>
    </xsl:template>

    <xsl:template match="packagedElement" mode="view">
		<xsl:variable name="name" select="@name"/>
		<xsl:variable name="filename" select="$properties/SchemaCreationProperties/ViewNamespaces/Namespace[@name=$name]/@location"/>
		<xsl:result-document href="{$filepath}{$filename}">
			<xsl:variable name="prefix" select="$properties/SchemaCreationProperties/ViewNamespaces/Namespace[@name=$name]/@prefix"/>
			<xsl:variable name="name" select="replace(@name, ':', '_')"/>
			<xs:schema version="1.0" elementFormDefault="qualified" attributeFormDefault="unqualified">
				<xsl:attribute name="targetNamespace">
					<xsl:text>ddi:</xsl:text>
					<xsl:value-of select="lower-case($name)"/>
					<xsl:text>:4_0</xsl:text>
				</xsl:attribute>
				<xsl:namespace name="{$prefix}" select="concat('ddi:',lower-case($name),':4_0')"/>
				<xsl:for-each select="$properties/SchemaCreationProperties/PackageNamespaces/Namespace">
					<xsl:namespace name="{@prefix}" select="concat('ddi:',lower-case(@name),':4_0')"/>
				</xsl:for-each>

				<xsl:comment>
					<xsl:text>This file was created by xmi2xsd version </xsl:text>
					<xsl:value-of select="$stylesheetVersion"/>
				</xsl:comment>
				<xs:include schemaLocation="library.xsd"/>
				<xs:element>
				    <xsl:attribute name="type">
				        <xsl:value-of select="$prefix"/>
				        <xsl:text>:DDI4</xsl:text>
				        <xsl:value-of select="@name"/>
				        <xsl:text>Type</xsl:text>
				    </xsl:attribute>
				    <xsl:attribute name="name">
				        <xsl:text>DDI4</xsl:text>
				        <xsl:value-of select="replace(@name, ':', '_')"/>
				    </xsl:attribute>
				    <!-- documentation -->
					<xs:annotation>
						<xs:documentation>
							<xsl:value-of select="//*/element[@xmi:idref=$name]/properties/@documentation"/>
						</xs:documentation>
					</xs:annotation>
				</xs:element>
				<xs:complexType>
				    <xsl:attribute name="name">
				        <xsl:text>DDI4</xsl:text>
				        <xsl:value-of select="@name"/>
				        <xsl:text>Type</xsl:text>
				    </xsl:attribute>
				    <xs:complexContent>
						<!-- documentation -->
						<xs:annotation>
							<xs:documentation>
								<xsl:value-of select="//*/element[@xmi:idref=$name]/properties/@documentation"/>
							</xs:documentation>
						</xs:annotation>
						<xs:extension>
							<xs:sequence>
								<xs:choice>
									<xsl:variable name="viewID" select="@xmi:id"/>
									<xsl:apply-templates select="//diagram[model/@package=$viewID]" mode="viewRoot"/>
								</xs:choice>
							</xs:sequence>
						</xs:extension>
					</xs:complexContent>
				</xs:complexType>
			</xs:schema>
		</xsl:result-document>
    </xsl:template>

    <xsl:template match="packagedElement" mode="package">
		<xsl:variable name="name" select="@name"/>
		<xsl:variable name="filename" select="$properties/SchemaCreationProperties/PackageNamespaces/Namespace[@name=$name]/@location"/>
		<xsl:result-document href="{$filepath}{$filename}">
			<xsl:variable name="prefix" select="$properties/SchemaCreationProperties/PackageNamespaces/Namespace[@name=$name]/@prefix"/>
			<xsl:variable name="name" select="replace(@name, ':', '_')"/>
			<xs:schema version="1.0" elementFormDefault="qualified" attributeFormDefault="unqualified">
				<xsl:attribute name="targetNamespace">
					<xsl:text>ddi:</xsl:text>
					<xsl:value-of select="lower-case($name)"/>
					<xsl:text>:4_0</xsl:text>
				</xsl:attribute>
				<xsl:namespace name="{$prefix}" select="concat('ddi:',lower-case($name),':4_0')"/>
				<xsl:for-each select="$properties/SchemaCreationProperties/PackageNamespaces/Namespace">
					<xsl:namespace name="{@prefix}" select="concat('ddi:',lower-case(@name),':4_0')"/>
				</xsl:for-each>
				<xsl:comment>
					<xsl:text>This file was created by xmi2xsd version </xsl:text>
					<xsl:value-of select="$stylesheetVersion"/>
				</xsl:comment>
				<xs:include schemaLocation="library.xsd"/>
				<xsl:apply-templates select="packagedElement[@xmi:type='uml:Class']" mode="class"/>
			</xs:schema>
		</xsl:result-document>
    </xsl:template>
	
	<xsl:template match="diagram" mode="viewRoot">
		<xsl:for-each select="elements/element">
			<xsl:variable name="oID" select="@subject"/>
			<xsl:variable name="pName" select="//packagedElement[@xmi:id=$oID]/../@name"/>
			<xsl:variable name="prefix" select="$properties/SchemaCreationProperties/PackageNamespaces/Namespace[@name=$pName]/@prefix"/>
			<xs:element>
				<xsl:attribute name="name">
					<xsl:value-of select="replace(//packagedElement[@xmi:id=$oID]/@name, ':', '_')"/>
				</xsl:attribute>
				<xsl:attribute name="type">
					<xsl:value-of select="$prefix"/>
					<xsl:text>:</xsl:text>
					<xsl:value-of select="ddifunc:cleanName(//packagedElement[@xmi:id=$oID]/@name)"/>
					<xsl:text>Type</xsl:text>
				</xsl:attribute>
			</xs:element>
		</xsl:for-each>
	</xsl:template>

    <xsl:template match="packagedElement" mode="class">
        <xsl:variable name="paid">
            <xsl:value-of select="generalization/@general"/>
        </xsl:variable>
        <xsl:variable name="tmpname" select="@name"/>
		<xsl:variable name="mns" select="../@name"/>

		<xs:element>
			<xsl:attribute name="name">
				<xsl:value-of select="replace(@name, ':', '_')"/>
			</xsl:attribute>
			<xsl:attribute name="type">
				<xsl:value-of
					select="$properties/SchemaCreationProperties/PackageNamespaces/Namespace[@name=$mns]/@prefix"/>
				<xsl:text>:</xsl:text>
				<xsl:value-of select="@name"/>
				<xsl:text>Type</xsl:text>
			</xsl:attribute>
			<xsl:if test="@isAbstract='true'">
				<xsl:attribute name="abstract">
					<xsl:text>true</xsl:text>
				</xsl:attribute>
			</xsl:if>

			<!-- documentation -->
			<xs:annotation>
				<xs:documentation>
					<xsl:value-of select="//*/element[@name=$tmpname]/properties/@documentation"/>
				</xs:documentation>
			</xs:annotation>
		</xs:element>

		<xsl:variable name="gid" select="generalization/@general"/>
		<xsl:variable name="tns" select="//packagedElement[@xmi:id=$gid]/../@name"/>
		
        <xs:complexType>
            <xsl:attribute name="name">
                <xsl:value-of select="ddifunc:cleanName(@name)"/>
                <xsl:text>Type</xsl:text>
            </xsl:attribute>
            <xs:complexContent>
                <!-- documentation -->
                <xs:annotation>
                    <xs:documentation>
                        <xsl:value-of select="//*/element[@name=$tmpname]/properties/@documentation"
                        />
                    </xs:documentation>
                </xs:annotation>
                <xs:extension>
					<xsl:if test="generalization">
						<xsl:attribute name="base">
							<xsl:value-of
								select="$properties/SchemaCreationProperties/PackageNamespaces/Namespace[@name=$tns]/@prefix"/>
							<xsl:text>:</xsl:text>
							<xsl:value-of
								select="//packagedElement[@xmi:id=$paid]/@name"/>
							<xsl:text>Type</xsl:text>
						</xsl:attribute>
					</xsl:if>
                    <xs:sequence>
                        <xsl:apply-templates select="ownedAttribute[@xmi:type='uml:Property']"/>
                    </xs:sequence>
                </xs:extension>
            </xs:complexContent>
        </xs:complexType>
    </xsl:template>

    <xsl:template match="ownedAttribute">
        <xsl:choose>
            <!-- aggregation / association -->
            <xsl:when test="@aggregation or @association">
                <xsl:variable name="paid" select="@association"/>
                <xs:element type="ddic:ReferenceType">
                    <xsl:for-each select="//packagedElement[@xmi:id=$paid]">
                        <xsl:attribute name="name">
                            <xsl:value-of select="ddifunc:to-upper-cc(@name)"/>
                        </xsl:attribute>
                        <xsl:if test="ownedEnd/lowerValue/@value!=''">
                            <xsl:attribute name="minOccurs">
                                <xsl:value-of select="ownedEnd/lowerValue/@value"/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:if test="ownedEnd/upperValue/@value!=''">
                            <xsl:choose>
                                <xsl:when test="ownedEnd/upperValue/@value='-1'">
                                    <xsl:attribute name="maxOccurs">
                                        <xsl:text>unbounded</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="maxOccurs">
                                        <xsl:value-of select="ownedEnd/upperValue/@value"/>
                                    </xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:for-each>
                </xs:element>
            </xsl:when>
            <xsl:otherwise>
                <!-- attribute -->
                <xs:element>
                    <xsl:attribute name="name">
                        <xsl:value-of select="ddifunc:to-upper-cc(@name)"/>
                    </xsl:attribute>

                    <!-- define xs type -->
                    <xsl:variable name="xmitype" select="lower-case(type/@xmi:type)"/>
                    <xsl:variable name="xmiidref" select="lower-case(type/@xmi:idref)"/>
                    <xsl:choose>
                        <xsl:when test="$xmitype = 'uml:primitivetype'">
                            <xsl:call-template name="defineType">
                                <xsl:with-param name="xmitype"
                                    select="lower-case(tokenize(type/@href,'#')[last()])"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$xmitype != ''">
                            <xsl:call-template name="defineType">
                                <xsl:with-param name="xmitype" select="$xmitype"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="defineType">
                                <xsl:with-param name="xmitype" select="ddifunc:cleanName($xmiidref)">                                    
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>

                    <!-- define min - max -->
                    <xsl:if test="lowerValue/@value!=''">
                        <xsl:attribute name="minOccurs">
                            <xsl:value-of select="lowerValue/@value"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="upperValue/@value!=''">
                        <xsl:choose>
                            <xsl:when test="upperValue/@value='-1'">
                                <xsl:attribute name="maxOccurs">
                                    <xsl:text>unbounded</xsl:text>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="maxOccurs">
                                    <xsl:value-of select="upperValue/@value"/>
                                </xsl:attribute>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </xs:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="defineType">
        <xsl:param name="xmitype"/>

        <xsl:attribute name="type">
            <xsl:choose>
                <!-- string -->
                <xsl:when test="contains($xmitype, 'string')">
                    <xsl:text>xs:string</xsl:text>
                </xsl:when>
                <xsl:when test="contains($xmitype,  'char')">
                    <xsl:text>xs:string</xsl:text>
                </xsl:when>

                <!-- uml unlimitednatural eq string -->
                <xsl:when test="contains($xmitype,  'unlimitednatural')">
                    <xsl:text>xs:string</xsl:text>
                </xsl:when>

                <!-- boolean -->
                <xsl:when test="contains($xmitype,  'boolean')">
                    <xsl:text>xs:boolean</xsl:text>
                </xsl:when>

                <!-- numeric -->
                <xsl:when test="contains($xmitype, 'integer')">
                    <xsl:text>xs:int</xsl:text>
                </xsl:when>
                <xsl:when test="contains($xmitype, 'long')">
                    <xsl:text>xs:long</xsl:text>
                </xsl:when>

                <!-- real -->
                <xsl:when test="contains($xmitype, 'float')">
                    <xsl:text>xs:decimal</xsl:text>
                </xsl:when>

                <!-- date time -->
                <xsl:when test="contains($xmitype, 'datetime')">
                    <xsl:text>xs:dateTime</xsl:text>
                </xsl:when>

                <!-- TODO simplify with template ddic types ... -->
                <xsl:when test="contains($xmitype, 'internationalisedstring')">
                    <xsl:text>ddic:InternationalisedString</xsl:text>
                </xsl:when>

                <!-- uri -->
                <xsl:when test="contains($xmitype, 'uri')">
                    <xsl:text>xs:anyURI</xsl:text>
                </xsl:when>

                <!-- empty and todo types -->
                <xsl:when test="$xmitype =''">
                    <xsl:text>ALERT empty type</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>TODO </xsl:text>
                    <xsl:value-of select="type/@xmi:type"/>
                </xsl:otherwise>

                <!-- ToDo more data types -->
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
</xsl:stylesheet>
