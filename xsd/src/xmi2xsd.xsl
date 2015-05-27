<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:uml="http://www.omg.org/spec/UML/20110701" 
	xmlns:xmi="http://www.omg.org/spec/XMI/20110701" xmlns:ddifunc="ddi:functions"
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
	<xsl:variable name="stylesheetVersion">2.2.0</xsl:variable>
    <xsl:variable name="includedPackages">
        <xsl:for-each select="//packagedElement[@xmi:id='ddi4_model']/packagedElement[@xmi:type='uml:Package']">
            <xsl:text>|</xsl:text>
            <xsl:value-of select="@name"/>
        </xsl:for-each>
        <xsl:text>|</xsl:text>
    </xsl:variable>

    <xsl:template match="xmi:XMI">
        <protocol>
            <xsl:comment>
				<xsl:text>This file was creanguageated by xmi2xsd version </xsl:text>
				<xsl:value-of select="$stylesheetVersion"/>
			</xsl:comment>
            
        <xsl:apply-templates select="//packagedElement[@xmi:id='ddi4_model']/packagedElement[@xmi:type='uml:Package' and @name='ComplexDataTypes']"
            mode="datatypes"/>
		<xsl:apply-templates select="//packagedElement[@xmi:id='ddi4_model']/packagedElement[@xmi:type='uml:Package' and @name!='ComplexDataTypes' and @name!='Primitives']"
            mode="package"/>
        <xsl:apply-templates select="//packagedElement[@xmi:id='ddi4_views']/packagedElement[@xmi:type='uml:Package']"
			mode="view"/>
        </protocol>
    </xsl:template>

    <xsl:template match="packagedElement" mode="view">
		<xsl:variable name="name" select="@name"/>
		<xsl:variable name="filename" select="$properties/SchemaCreationProperties/ViewNamespaces/Namespace[@name=$name]/@location"/>
		<xsl:result-document href="{$filepath}/{$filename}">
			<xsl:variable name="prefix" select="$properties/SchemaCreationProperties/ViewNamespaces/Namespace[@name=$name]/@prefix"/>
			<xsl:variable name="name" select="replace(@name, ':', '_')"/>
			<xs:schema version="1.0" elementFormDefault="qualified" attributeFormDefault="unqualified">
				<xsl:attribute name="targetNamespace">
					<xsl:text>ddi:</xsl:text>
					<xsl:value-of select="lower-case($name)"/>
					<xsl:text>:4_0</xsl:text>
				</xsl:attribute>
				<xsl:namespace name="" select="concat('ddi:',lower-case($name),':4_0')"/>
				<xsl:for-each select="$properties/SchemaCreationProperties/PackageNamespaces/Namespace">
				    <xsl:if test="contains($includedPackages, concat('|',@name,'|'))">
				        <xsl:namespace name="{@prefix}" select="concat('ddi:',lower-case(@name),':4_0')"/>
				    </xsl:if>
				</xsl:for-each>

				<xsl:comment>
					<xsl:text>This file was created by xmi2xsd version </xsl:text>
					<xsl:value-of select="$stylesheetVersion"/>
				</xsl:comment>
			    <xsl:for-each select="$properties/SchemaCreationProperties/PackageNamespaces/Namespace">
			        <xsl:if test="contains($includedPackages, concat('|',@name,'|'))">
    		            <xs:import>
    		                <xsl:attribute name="schemaLocation">
    		                    <xsl:value-of select="@location"/>
    		                </xsl:attribute>
    		                <xsl:attribute name="namespace">
    		                    <xsl:value-of select="concat('ddi:',lower-case(@name),':4_0')"/>
    		                </xsl:attribute>
    		            </xs:import>
			        </xsl:if>
			    </xsl:for-each>
			    
			    <xs:import namespace="http://www.w3.org/XML/1998/namespace" schemaLocation="xml.xsd"/>
			    <xs:import namespace="http://www.w3.org/1999/xhtml" schemaLocation="ddi-xhtml11.xsd"/>
			    <xs:element>
				    <xsl:attribute name="type">
				        <xsl:text>DDI4</xsl:text>
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
					<!-- documentation -->
					<xs:annotation>
						<xs:documentation>
							<xsl:value-of select="//*/element[@xmi:idref=$name]/properties/@documentation"/>
						</xs:documentation>
					</xs:annotation>
					<xs:sequence>
    					<xsl:variable name="viewID" select="@xmi:id"/>
    					<xsl:apply-templates select="//diagram[model/@package=$viewID]" mode="viewRoot"/>
					</xs:sequence>
				</xs:complexType>
			</xs:schema>
		</xsl:result-document>
    </xsl:template>

    <xsl:template match="packagedElement" mode="package">
        <xsl:variable name="name" select="@name"/>
        <xsl:variable name="filename" select="$properties/SchemaCreationProperties/PackageNamespaces/Namespace[@name=$name]/@location"/>
        <xsl:choose>
            <xsl:when test="$filename=''">
                <Error>
                    <xsl:text>No properties found in xsd-properties.xml for: </xsl:text>
                    <xsl:value-of select="$name"/>
                </Error>
            </xsl:when>
            <xsl:otherwise>
                <xsl:result-document href="{$filepath}/{$filename}">
                    <xsl:variable name="prefix" select="$properties/SchemaCreationProperties/PackageNamespaces/Namespace[@name=$name]/@prefix"/>
                    <xsl:variable name="name" select="replace(@name, ':', '_')"/>
                    <xs:schema version="1.0" elementFormDefault="qualified" attributeFormDefault="unqualified">
                        <xsl:attribute name="targetNamespace">
                            <xsl:text>ddi:</xsl:text>
                            <xsl:value-of select="lower-case($name)"/>
                            <xsl:text>:4_0</xsl:text>
                        </xsl:attribute>
                        <xsl:for-each select="$properties/SchemaCreationProperties/PackageNamespaces/Namespace">
                            <xsl:if test="contains($includedPackages, concat('|',@name,'|'))">
                                <xsl:choose>
                                    <xsl:when test="@prefix=$prefix">
                                        <xsl:namespace name="" select="concat('ddi:',lower-case(@name),':4_0')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:namespace name="{@prefix}" select="concat('ddi:',lower-case(@name),':4_0')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:comment>
					<xsl:text>This file was created by xmi2xsd version </xsl:text>
					<xsl:value-of select="$stylesheetVersion"/>
				</xsl:comment>
                        <xsl:for-each select="$properties/SchemaCreationProperties/PackageNamespaces/Namespace">
                            <xsl:if test="contains($includedPackages, concat('|',@name,'|'))">
                                <xsl:if test="@prefix!= $prefix">
                                    <xs:import>
                                        <xsl:attribute name="schemaLocation">
                                            <xsl:value-of select="@location"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="namespace">
                                            <xsl:value-of select="concat('ddi:',lower-case(@name),':4_0')"/>
                                        </xsl:attribute>
                                    </xs:import>
                                </xsl:if>
                            </xsl:if>
                        </xsl:for-each>
                        
                        <xs:import namespace="http://www.w3.org/XML/1998/namespace" schemaLocation="xml.xsd"/>
                        <xs:import namespace="http://www.w3.org/1999/xhtml" schemaLocation="ddi-xhtml11.xsd"/>
                        <xsl:apply-templates select="packagedElement[@xmi:type='uml:Class']" mode="class"/>
                    </xs:schema>
                </xsl:result-document>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="packagedElement" mode="datatypes">
        <xsl:variable name="name" select="@name"/>
        <xsl:variable name="filename" select="$properties/SchemaCreationProperties/PackageNamespaces/Namespace[@name=$name]/@location"/>
        <xsl:result-document href="{$filepath}/{$filename}">
            <xsl:variable name="prefix" select="$properties/SchemaCreationProperties/PackageNamespaces/Namespace[@name=$name]/@prefix"/>
            <xsl:variable name="name" select="replace(@name, ':', '_')"/>
            <xs:schema version="1.0" elementFormDefault="qualified" attributeFormDefault="unqualified">
                <xsl:attribute name="targetNamespace">
                    <xsl:text>ddi:</xsl:text>
                    <xsl:value-of select="lower-case($name)"/>
                    <xsl:text>:4_0</xsl:text>
                </xsl:attribute>
                <xsl:for-each select="$properties/SchemaCreationProperties/PackageNamespaces/Namespace">
                    <xsl:if test="contains($includedPackages, concat('|',@name,'|'))">
                        <xsl:choose>
                            <xsl:when test="@prefix=$prefix">
                                <xsl:namespace name="" select="concat('ddi:',lower-case(@name),':4_0')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:namespace name="{@prefix}" select="concat('ddi:',lower-case(@name),':4_0')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </xsl:for-each>
                <xsl:comment>
					<xsl:text>This file was created by xmi2xsd version </xsl:text>
					<xsl:value-of select="$stylesheetVersion"/>
				</xsl:comment>
                <xsl:for-each select="$properties/SchemaCreationProperties/PackageNamespaces/Namespace">
                    <xsl:if test="contains($includedPackages, concat('|',@name,'|'))">
                        <xsl:if test="@prefix!= $prefix">
                            <xs:import>
                                <xsl:attribute name="schemaLocation">
                                    <xsl:value-of select="@location"/>
                                </xsl:attribute>
                                <xsl:attribute name="namespace">
                                    <xsl:value-of select="concat('ddi:',lower-case(@name),':4_0')"/>
                                </xsl:attribute>
                            </xs:import>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
                
                <xs:import namespace="http://www.w3.org/XML/1998/namespace" schemaLocation="xml.xsd"/>
                <xs:import namespace="http://www.w3.org/1999/xhtml" schemaLocation="ddi-xhtml11.xsd"/>
                <xsl:apply-templates select="packagedElement[@xmi:type='uml:DataType']" mode="dataType"/>
                <xsl:apply-templates select="packagedElement[@xmi:type='uml:Enumeration']" mode="enumeration"/>
                <xsl:for-each select="packagedElement[@xmi:type='uml:Class']">
                    <xsl:variable name="isSimple">
                        <xsl:apply-templates select="." mode="isSimple"/>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="$isSimple='true'">
                            <xsl:apply-templates select="." mode="simple"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="." mode="class"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </xsl:for-each>
                <xs:complexType name="ReferenceType">
                    <xs:annotation>
                        <xs:documentation>Used for referencing an identified entity expressed in DDI XML, either by a URN and/or an ID. If both are supplied, the URN takes precedence. At a minimum, one or the other is required. The lateBound attribute has a boolean value, which - if set to true - indicates that the latest version should be used.</xs:documentation>
                    </xs:annotation>
                    <xs:simpleContent>
                        <xs:extension base="xs:string">
                            <xs:attribute name="isExternal" type="xs:boolean" default="false">
                                <xs:annotation>
                                    <xs:documentation>Indicates that the reference is made to an external source. If the value is true, then a URI must be provided.</xs:documentation>
                                </xs:annotation>
                            </xs:attribute>
                            <xs:attribute name="URI" type="xs:anyURI" use="optional">
                                <xs:annotation>
                                    <xs:documentation>URI identifying the location of an external reference.</xs:documentation>
                                </xs:annotation>
                            </xs:attribute>
                            <xs:attribute name="isReference" type="xs:boolean" fixed="true">
                                <xs:annotation>
                                    <xs:documentation>A fixed attribute value identifying which elements are references.</xs:documentation>
                                </xs:annotation>
                            </xs:attribute>
                            <xs:attribute name="lateBound" type="xs:boolean" default="false"/>
                            <xs:attribute name="objectLanguage" type="xs:language" use="optional">
                                <xs:annotation>
                                    <xs:documentation>Specifies the language (or language-locale pair) to use for display in references to objects which have multiple languages available.</xs:documentation>
                                </xs:annotation>
                            </xs:attribute>   
                            <xs:attribute name="sourceContext" type="xs:anyURI" use="optional">
                                <xs:annotation>
                                    <xs:documentation>Provide a DDI URN for the version of the parent maintainable that shows the full context for the referenced object. This is used only when the context of the object within the current version of a maintainable is important to the user and this version is later than the one containing the object itself. For example a occupation classification may be unchanged since version 1.0 of its maintainable but at the point of reference the current version of the maintainable containing the original structure is at version 2.0 etc..</xs:documentation>
                                </xs:annotation>
                            </xs:attribute>    
                        </xs:extension>
                    </xs:simpleContent>
                </xs:complexType>
            </xs:schema>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="diagram" mode="viewRoot">
		<xsl:for-each select="elements/element">
			<xsl:variable name="oID" select="@subject"/>
			<xsl:variable name="pName" select="//packagedElement[@xmi:id=$oID]/../@name"/>
			<xsl:variable name="prefix" select="$properties/SchemaCreationProperties/PackageNamespaces/Namespace[@name=$pName]/@prefix"/>
			<xs:element maxOccurs="unbounded">
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

    <xsl:template match="packagedElement" mode="enumeration">
        <xs:simpleType>
            <xsl:attribute name="name">
                <xsl:value-of select="@name"/>
                <xsl:text>Type</xsl:text>
            </xsl:attribute>
            <xs:restriction base="xs:NMTOKEN">
                <xsl:for-each select="ownedLiteral">
                    <xs:enumeration value="Nominal">
                        <xsl:attribute name="value">
                            <xsl:value-of select="@name"/>
                        </xsl:attribute>
                    </xs:enumeration>
                </xsl:for-each>
            </xs:restriction>
        </xs:simpleType>
    </xsl:template>
    
    <xsl:template match="packagedElement" mode="isSimple">
        <xsl:choose>
            <xsl:when test="ownedAttribute[type/@xmi:type!='uml:PrimitiveType']">
                <xsl:text>false</xsl:text>
            </xsl:when>
            <xsl:when test="ownedAttribute[(@name='content' and type/@xmi:type='uml:PrimitiveType' and not(contains(type/@href, 'anyURI'))) or type/@xmi:idref='xhtml:BlkNoForm.mix']">
                <xsl:text>true</xsl:text>
            </xsl:when>
            <xsl:when test="generalization/@general">
                <xsl:variable name="pid" select="generalization/@general"/>
                <xsl:apply-templates select="//packagedElement[@xmi:id=$pid]" mode="isSimple"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="packagedElement" mode="isXHMTL">
        <xsl:choose>
            <xsl:when test="ownedAttribute[type/@xmi:idref='xhtml:BlkNoForm.mix']">
                <xsl:text>true</xsl:text>
            </xsl:when>
            <xsl:when test="generalization/@general">
                <xsl:variable name="pid" select="generalization/@general"/>
                <xsl:apply-templates select="//packagedElement[@xmi:id=$pid]" mode="isXHMTL"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="packagedElement" mode="dataType">
        <xs:simpleType>
            <xsl:attribute name="name">
                <xsl:value-of select="@name"/>
                <xsl:text>Type</xsl:text>
            </xsl:attribute>
            <xs:restriction base="xs:string">
                <!-- TODO: currently we dont have the right place to put the pattern in for DataType elements in XMI -->
                <!--
                        <xsl:if test="">
                            <xs:pattern>
                                <xsl:attribute name="value">
                                    <xsl:value-of select=""/>
                                </xsl:attribute>
                            </xs:pattern>
                        </xsl:if>
                        -->
            </xs:restriction>
        </xs:simpleType>
    </xsl:template>
    
    <xsl:template match="packagedElement" mode="simple">
        <xsl:variable name="paid">
            <xsl:value-of select="generalization/@general"/>
        </xsl:variable>
        <xsl:variable name="isParentXHMLT">
            <xsl:apply-templates select="//packagedElement[@xmi:id=$paid]" mode="isXHMTL"/>
        </xsl:variable>
        <xsl:variable name="tmpname" select="@name"/>
        <xsl:choose>
            <xsl:when test="$isParentXHMLT='true'">
                <xs:complexType mixed="true">
                    <xsl:attribute name="name">
                        <xsl:value-of select="@name"/>
                        <xsl:text>Type</xsl:text>
                    </xsl:attribute>
                    <xs:complexContent>
                        <!-- documentation -->
                        <xs:annotation>
                            <xs:documentation>
                                <xsl:value-of select="//*/element[@name=$tmpname]/properties/@documentation"/>
                            </xs:documentation>
                        </xs:annotation>
                        <xs:extension>
                            <xsl:attribute name="base">
                                <xsl:value-of select="//packagedElement[@xmi:id=$paid]/@name"/>
                                <xsl:if test="generalization/@general='Reference'">
                                    <xsl:text>Reference</xsl:text>
                                </xsl:if>
                                <xsl:text>Type</xsl:text>
                            </xsl:attribute>
                            <xsl:apply-templates select="ownedAttribute[@name!='content']" mode="attribute"/>
                        </xs:extension>
                    </xs:complexContent>
                </xs:complexType>
            </xsl:when>
            <xsl:when test="count(ownedAttribute[@xmi:type='uml:Property'])=1 and ownedAttribute[@name='content']">
                <xs:simpleType>
                    <xsl:attribute name="name">
                        <xsl:value-of select="@name"/>
                        <xsl:text>Type</xsl:text>
                    </xsl:attribute>
                    <xs:restriction>
                        <xsl:attribute name="base">
                            <xsl:call-template name="defineType">
                                <xsl:with-param name="xmitype" select="lower-case(tokenize(ownedAttribute[@name='content']/type/@href,'#')[last()])"/>
                            </xsl:call-template>
                        </xsl:attribute>
                        <!-- TODO: currently we dont have the right place to put the pattern in for DataType elements in XMI -->
                        <!--
                        <xsl:if test="">
                            <xs:pattern>
                                <xsl:attribute name="value">
                                    <xsl:value-of select=""/>
                                </xsl:attribute>
                            </xs:pattern>
                        </xsl:if>
                        -->
                    </xs:restriction>
                </xs:simpleType>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="ownedAttribute[@name='content']/type/@xmi:idref='xhtml:BlkNoForm.mix'">
                        <xs:complexType mixed="true">
                            <xsl:attribute name="name">
                                <xsl:value-of select="@name"/>
                                <xsl:text>Type</xsl:text>
                            </xsl:attribute>
                            <xs:choice maxOccurs="unbounded" minOccurs="0">
                                <xs:group ref="xhtml:BlkNoForm.mix"/>
                            </xs:choice>
                            <xsl:apply-templates select="ownedAttribute[@name!='content']" mode="attribute"/>
                        </xs:complexType>
                    </xsl:when>
                    <xsl:otherwise>
                        <xs:complexType>
                            <xsl:attribute name="name">
                                <xsl:value-of select="@name"/>
                                <xsl:text>Type</xsl:text>
                            </xsl:attribute>
                            <xs:simpleContent>
                                <xs:extension base="xs:string">
                                    <xsl:attribute name="base">
                                        <xsl:choose>
                                            <xsl:when test="ownedAttribute[@name='content']">
                                                <xsl:call-template name="defineType">
                                                    <xsl:with-param name="xmitype" select="lower-case(tokenize(ownedAttribute[@name='content']/type/@href,'#')[last()])"/>
                                                </xsl:call-template>
                                            </xsl:when>
                                            <xsl:when test="generalization/@general">
                                                <xsl:value-of select="generalization/@general"/>
                                                <xsl:text>Type</xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                ERROR
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
                                    <xsl:apply-templates select="ownedAttribute[@name!='content']" mode="attribute"/>
                                </xs:extension>
                            </xs:simpleContent>
                        </xs:complexType>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="packagedElement" mode="class">
        <xsl:variable name="paid">
            <xsl:value-of select="generalization/@general"/>
        </xsl:variable>
        <xsl:variable name="tmpname" select="@name"/>
		<xsl:variable name="mns" select="../@name"/>
        <xsl:variable name="overriddenProperties">
            <xsl:call-template name="determineOverride">
                <xsl:with-param name="source" select="."/>
                <xsl:with-param name="ancestor" select="//packagedElement[@xmi:id=$paid]"/>
            </xsl:call-template>
        </xsl:variable>
        
		<xs:element>
			<xsl:attribute name="name">
				<xsl:value-of select="replace(@name, ':', '_')"/>
			</xsl:attribute>
			<xsl:attribute name="type">
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
		
        <xsl:if test="$overriddenProperties!=''">
            <xsl:comment>
                <xsl:text>overrides properties: </xsl:text>
                <xsl:value-of select="$overriddenProperties"></xsl:value-of>
            </xsl:comment>
            <xs:complexType>
                <xsl:attribute name="name">
                    <xsl:value-of select="ddifunc:cleanName(@name)"/>
                    <xsl:text>RestrictionType</xsl:text>
                </xsl:attribute>
                <xs:complexContent>
                    <xs:annotation>
                        <xs:documentation>
                            <xsl:text>overridden properties: </xsl:text>
                            <xsl:value-of select="$overriddenProperties"></xsl:value-of>
                        </xs:documentation>
                    </xs:annotation>
                    <xs:restriction>
                        <xsl:attribute name="base">
                            <xsl:if test="$tns!=$mns">
                                <xsl:value-of
                                    select="$properties/SchemaCreationProperties/PackageNamespaces/Namespace[@name=$tns]/@prefix"/>
                                <xsl:text>:</xsl:text>
                            </xsl:if>
                            <xsl:value-of
                                select="//packagedElement[@xmi:id=$paid]/@name"/>
                            <xsl:if test="generalization/@general='Reference'">
                                <xsl:text>Reference</xsl:text>
                            </xsl:if>
                            <xsl:text>Type</xsl:text>
                        </xsl:attribute>
                        <xs:sequence>
                            <xsl:apply-templates select="//packagedElement[@xmi:id=$paid]" mode="fillUpWhatsLeft">
                                <xsl:with-param name="leftOut" select="$overriddenProperties"/>
                            </xsl:apply-templates>
                        </xs:sequence>
                    </xs:restriction>
                </xs:complexContent>
            </xs:complexType>
        </xsl:if>
        
        <xs:complexType>
            <xsl:attribute name="name">
                <xsl:value-of select="ddifunc:cleanName(@name)"/>
                <xsl:text>Type</xsl:text>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="generalization">
                    <xs:complexContent>
                        <!-- documentation -->
                        <xs:annotation>
                            <xs:documentation>
                                <xsl:value-of select="//*/element[@name=$tmpname]/properties/@documentation"
                                />
                            </xs:documentation>
                        </xs:annotation>
                        <xs:extension>
                            <xsl:attribute name="base">
                                <xsl:choose>
                                    <xsl:when test="$overriddenProperties!=''">
                                        <xsl:value-of select="ddifunc:cleanName(@name)"/>
                                        <xsl:text>Restriction</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:if test="$tns!=$mns">
                                            <xsl:value-of
                                                select="$properties/SchemaCreationProperties/PackageNamespaces/Namespace[@name=$tns]/@prefix"/>
                                            <xsl:text>:</xsl:text>
                                        </xsl:if>
                                        <xsl:value-of
                                            select="//packagedElement[@xmi:id=$paid]/@name"/>
                                        <xsl:if test="generalization/@general='Reference'">
                                            <xsl:text>Reference</xsl:text>
                                        </xsl:if>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text>Type</xsl:text>
                            </xsl:attribute>
                            <xs:sequence>
                                <xsl:apply-templates select="ownedAttribute[@xmi:type='uml:Property' and not(ends-with(type/@href,'anguage') or ends-with(type/@xmi:type,'anguage') or ends-with(@xmi:type,'anguage'))]"/>
                            </xs:sequence>
                            <xsl:apply-templates select="ownedAttribute[@xmi:type='uml:Property' and (ends-with(type/@href,'anguage') or ends-with(type/@xmi:type,'anguage') or ends-with(@xmi:type,'anguage'))]" mode="attribute"/>
                        </xs:extension>
                    </xs:complexContent>
                </xsl:when>
                <xsl:otherwise>
                    <!-- documentation -->
                    <xs:annotation>
                        <xs:documentation>
                            <xsl:value-of select="//*/element[@name=$tmpname]/properties/@documentation"
                            />
                        </xs:documentation>
                    </xs:annotation>
                    <xs:sequence>
                        <xsl:apply-templates select="ownedAttribute[@xmi:type='uml:Property' and not(ends-with(type/@href,'anguage') or ends-with(type/@xmi:type,'anguage') or ends-with(@xmi:type,'anguage'))]"/>
                    </xs:sequence>
                    <xsl:apply-templates select="ownedAttribute[@xmi:type='uml:Property' and (ends-with(type/@href,'anguage') or ends-with(type/@xmi:type,'anguage') or ends-with(@xmi:type,'anguage'))]" mode="attribute"/>
                </xsl:otherwise>
            </xsl:choose>
        </xs:complexType>
    </xsl:template>
    
    <xsl:template match="ownedAttribute" mode="attribute">
        <xs:attribute>
                <xsl:choose>
                    <xsl:when test="lower-case(@name)='xmllang'">
                        <xsl:attribute name="ref">
                            <xsl:text>xml:lang</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="use"><xsl:text>required</xsl:text></xsl:attribute>
                    </xsl:when>
                    <xsl:when test="ends-with(type/@href,'anguage') or ends-with(type/@xmi:type,'anguage') or ends-with(@xmi:type,'anguage')">
                        <xsl:attribute name="name">
                            <xsl:value-of select="@name"/>
                        </xsl:attribute>
                        <xsl:attribute name="type">
                            <xsl:text>xs:language</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="use"><xsl:text>optional</xsl:text></xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="name">
                            <xsl:value-of select="@name"/>
                        </xsl:attribute>
                        <xsl:attribute name="type">
                            <!-- define xs type -->
                            <xsl:variable name="xmitype" select="type/@xmi:type"/>
                            <xsl:variable name="xmiidref" select="type/@xmi:idref"/>
                            <xsl:choose>
                                <xsl:when test="lower-case($xmitype) = 'uml:primitivetype'">
                                    <xsl:call-template name="defineType">
                                        <xsl:with-param name="xmitype"
                                            select="lower-case(tokenize(type/@href,'#')[last()])"/>
                                        <xsl:with-param name="package" select="../../@name"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="$xmitype != ''">
                                    <xsl:call-template name="defineType">
                                        <xsl:with-param name="xmitype" select="$xmitype"/>
                                        <xsl:with-param name="package" select="../../@name"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="defineType">
                                        <xsl:with-param name="xmitype" select="$xmiidref"/>
                                        <xsl:with-param name="package" select="../../@name"/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="use">
                            <xsl:choose>
                                <xsl:when test="lowerValue/@value='1'"><xsl:text>required</xsl:text></xsl:when>
                                <xsl:otherwise><xsl:text>optional</xsl:text></xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <!-- TODO: No example for that in XMI -->
                        <!-- xsl:attribute name="default"><xsl:text>optional</xsl:text></xsl:attribute -->
                    </xsl:otherwise>
                </xsl:choose>
        </xs:attribute>
    </xsl:template>
        
    <xsl:template match="ownedAttribute">
        <xsl:param name="leftOut"/>
        <xsl:choose>
            <!-- aggregation / association -->
            <xsl:when test="@aggregation or @association">
                <xsl:variable name="paid" select="@association"/>
                <xsl:variable name="nameCheck">
                    <xsl:text>;_</xsl:text>
                    <xsl:value-of select="substring-before(substring-after(@association, '_'), '_')"/>
                    <xsl:text>_;</xsl:text>
                </xsl:variable>
                <xsl:if test="not(contains($leftOut, $nameCheck))">
                    <xs:element>
                        <xsl:attribute name="type">
                            <xsl:if test="../../@name!='ComplexDataTypes'">
                                <xsl:value-of select="$properties/SchemaCreationProperties/PackageNamespaces/Namespace[@name='ComplexDataTypes']/@prefix"/>
                                <xsl:text>:</xsl:text>
                            </xsl:if>
                            <xsl:text>ReferenceType</xsl:text>
                        </xsl:attribute>
                        <xsl:for-each select="//packagedElement[@xmi:id=$paid and @xmi:type='uml:Association']">
                            <xsl:attribute name="name">
                                <xsl:value-of select="ddifunc:to-upper-cc(@name)"/>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="ownedEnd/lowerValue[1]/@value!=''">
                                    <xsl:attribute name="minOccurs">
                                        <xsl:value-of select="ownedEnd/lowerValue[1]/@value"/>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="minOccurs">0</xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="ownedEnd/upperValue[1]/@value!=''">
                                <xsl:choose>
                                    <xsl:when test="ownedEnd/upperValue[1]/@value='-1'">
                                        <xsl:attribute name="maxOccurs">
                                            <xsl:text>unbounded</xsl:text>
                                        </xsl:attribute>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="maxOccurs">
                                            <xsl:value-of select="ownedEnd/upperValue[1]/@value"/>
                                        </xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:if>
                        </xsl:for-each>
                    </xs:element>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <!-- attribute -->
                <xsl:variable name="nameCheck">
                    <xsl:text>;</xsl:text>
                    <xsl:value-of select="@name"/>
                    <xsl:text>;</xsl:text>
                </xsl:variable>
                <xsl:if test="not(contains($leftOut, $nameCheck))">
                    <xs:element>
                        <xsl:attribute name="name">
                            <xsl:value-of select="ddifunc:to-upper-cc(@name)"/>
                        </xsl:attribute>
                        
                        <!-- define xs type -->
                        <xsl:variable name="xmitype" select="type/@xmi:type"/>
                        <xsl:variable name="xmiidref" select="type/@xmi:idref"/>
                        <xsl:choose>
                            <xsl:when test="lower-case($xmitype) = 'uml:primitivetype'">
                                <xsl:call-template name="defineType">
                                    <xsl:with-param name="xmitype"
                                        select="lower-case(tokenize(type/@href,'#')[last()])"/>
                                    <xsl:with-param name="package" select="../../@name"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="$xmitype != ''">
                                <xsl:call-template name="defineType">
                                    <xsl:with-param name="xmitype" select="$xmitype"/>
                                    <xsl:with-param name="package" select="../../@name"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="defineType">
                                    <xsl:with-param name="xmitype" select="$xmiidref"/>
                                    <xsl:with-param name="package" select="../../@name"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                        <!-- define min - max -->
                        <xsl:choose>
                            <xsl:when test="ownedEnd/lowerValue[1]/@value!=''">
                                <xsl:attribute name="minOccurs">
                                    <xsl:value-of select="ownedEnd/lowerValue[1]/@value"/>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="minOccurs">0</xsl:attribute>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="ownedEnd/upperValue[1]/@value!=''">
                            <xsl:choose>
                                <xsl:when test="ownedEnd/upperValue[1]/@value='-1'">
                                    <xsl:attribute name="maxOccurs">
                                        <xsl:text>unbounded</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="maxOccurs">
                                        <xsl:value-of select="ownedEnd/upperValue[1]/@value"/>
                                    </xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </xs:element>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="defineType">
        <xsl:param name="xmitype"/>
        <xsl:param name="package"></xsl:param>
        
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
                <xsl:when test="contains($xmitype, 'real')">
                    <xsl:text>xs:decimal</xsl:text>
                </xsl:when>
                
                <!-- date time -->
                <xsl:when test="contains($xmitype, 'datetime')">
                    <xsl:text>xs:dateTime</xsl:text>
                </xsl:when>

                <!-- uri -->
                <xsl:when test="contains($xmitype, 'uri')">
                    <xsl:text>xs:anyURI</xsl:text>
                </xsl:when>
                
                <!-- language -->
                <xsl:when test="contains($xmitype, 'language')">
                    <xsl:text>xs:language</xsl:text>
                </xsl:when>
                
                <xsl:when test="//packagedElement[@name='ComplexDataTypes']/packagedElement[@name=$xmitype]">
                    <xsl:if test="$package!='ComplexDataTypes'">
                        <xsl:value-of select="$properties/SchemaCreationProperties/PackageNamespaces/Namespace[@name='ComplexDataTypes']/@prefix"/>
                        <xsl:text>:</xsl:text>
                    </xsl:if>
                    <xsl:value-of select="$xmitype"/>
                    <xsl:text>Type</xsl:text>
                </xsl:when>
                
                <!-- empty and todo types -->
                <xsl:when test="$xmitype =''">
                    <xsl:text>ALERT empty type</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>TODO </xsl:text>
                    <xsl:value-of select="type/@xmi:type"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template name="determineOverride">
        <xsl:param name="source"/>
        <xsl:param name="ancestor"/>
        <xsl:for-each select="$source/ownedAttribute[@xmi:type='uml:Property']">
            <xsl:variable name="name" select="@name"/>
            <xsl:choose>
                <xsl:when test="@aggregation or @association">
                    <xsl:variable name="middleName">
                        <xsl:text>_</xsl:text>
                        <xsl:value-of select="substring-before(substring-after(@association, '_'), '_')"/>
                        <xsl:text>_</xsl:text>
                    </xsl:variable>
                    <xsl:if test="$ancestor/ownedAttribute[@xmi:type='uml:Property' and contains(@association, $middleName)]">
                        <xsl:text>;</xsl:text>
                        <xsl:value-of select="$middleName"/>
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$ancestor/ownedAttribute[@xmi:type='uml:Property' and @name=$name]">
                        <xsl:text>;</xsl:text>
                        <xsl:value-of select="$name"/>
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:if test="$ancestor/generalization/@general">
            <xsl:variable name="gid" select="$ancestor/generalization/@general"></xsl:variable>
            <xsl:call-template name="determineOverride">
                <xsl:with-param name="source" select="$source"/>
                <xsl:with-param name="ancestor" select="//packagedElement[@xmi:id=$gid]"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="packagedElement" mode="fillUpWhatsLeft">
        <xsl:param name="leftOut"/>
        <xsl:apply-templates select="ownedAttribute[@xmi:type='uml:Property' and not(ends-with(type/@href,'anguage') or ends-with(type/@xmi:type,'anguage') or ends-with(@xmi:type,'anguage'))]">
            <xsl:with-param name="leftOut" select="$leftOut"/>
        </xsl:apply-templates>
        <xsl:if test="generalization/@general">
            <xsl:variable name="gid" select="generalization/@general"></xsl:variable>
            <xsl:apply-templates select="//packagedElement[@xmi:id=$gid]" mode="fillUpWhatsLeft">
                <xsl:with-param name="leftOut" select="$leftOut"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
