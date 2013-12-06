<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"  
    xmlns:uml="http://schema.omg.org/spec/UML/2.1" 
    xmlns:xmi="http://schema.omg.org/spec/XMI/2.1"
    xmlns:ddic="Core"
    xmlns:ddifunc="ddi:functions"
    exclude-result-prefixes="ddifunc uml xmi"
    version="2.0">
    
    <xsl:import href="support.xsl"/>
    
    <xsl:param name="processedNamespace"/>
    
    <xsl:variable name="properties" select="document('SchemaCreationProperties.xml')"/>
    
  <!--  <xsl:param name="primaryNamespaceURI">http://www.ohmygodmywifeisgerman.com</xsl:param>
    <xsl:param name="namespacePrefix">http://some.prefix.com/names/</xsl:param>-->
    
    <xsl:template match="xmi:XMI">
            <!-- <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" 
                xmlns="ddi:datacollection:3_1" 
                xmlns:r="ddi:reusable:3_1" 
                xmlns:l="ddi:logicalproduct:3_1" 
                targetNamespace="ddi:datacollection:3_1" 
                elementFormDefault="qualified" 
                attributeFormDefault="unqualified"> 
            -->
            <xsl:choose>
                <xsl:when test="$processedNamespace!=''">
                    <xs:schema version="1.0" targetNamespace="{$processedNamespace}">
                        <xsl:namespace name="" select="$processedNamespace"/>
                        <xsl:for-each select="$properties/SchemaCreationProperties/Namespaces/Namespace[@name=$processedNamespace]/Import">
                            <xsl:variable name="ns-prefix" select="text()"/>
                            <xsl:variable name="ns-namespace" select="$properties/SchemaCreationProperties/Namespaces/Namespace[@prefix=$ns-prefix]/@name"/>
                            <xsl:namespace name="{$ns-prefix}" select="$ns-namespace"/>
                        </xsl:for-each>
                        <xsl:for-each select="$properties/SchemaCreationProperties/Namespaces/Namespace[@name=$processedNamespace]/Import">
                            <xsl:variable name="ns-prefix" select="text()"/>
                            <xs:import>
                                <xsl:attribute name="namespace"><xsl:value-of select="$properties/SchemaCreationProperties/Namespaces/Namespace[@prefix=$ns-prefix]/@name"/></xsl:attribute>
                                <xsl:attribute name="schemaLocation"><xsl:value-of select="$properties/SchemaCreationProperties/Namespaces/Namespace[@prefix=$ns-prefix]/@location"/></xsl:attribute>
                            </xs:import>
                        </xsl:for-each>
                            <!--<xsl:value-of select="$properties/SchemaCreationProperties/Namespaces/Namespace[@name=$processedNamespace]/@prefix"/>-->
                        <xsl:apply-templates select="//packagedElement[@xmi:type='uml:Package' and @name=$processedNamespace]" mode="package"/>
                    </xs:schema>
                </xsl:when>
                <xsl:otherwise>
                    <xs:schema version="1.0">
                        <xsl:apply-templates select="//packagedElement[@xmi:type='uml:Package']" mode="package"/>
                    </xs:schema>
                </xsl:otherwise>
            </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="packagedElement" mode="package">
<!-- ToDo naming package with the the content of @name -->
        <xsl:apply-templates select="packagedElement[@xmi:type='uml:Class']" mode="class"/>
    </xsl:template>
    
    <xsl:template match="packagedElement" mode="class">
        <xsl:variable name="paid"><xsl:value-of select="generalization/@general"/></xsl:variable>
        <xs:element>
            <xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
            <xsl:attribute name="type"><xsl:value-of select="@name"/><xsl:text>Type</xsl:text></xsl:attribute>
            <xsl:if test="@isAbstract='true'">
                <xsl:attribute name="abstract"><xsl:text>true</xsl:text></xsl:attribute>
            </xsl:if>
            <!-- substitutionGoup should be left out. The sollution is the root element to contain 
                aggegations for all elements in a given namespace. the overall root element will then 
                have to contain all namespace root elements and act as a bracket. -->
            <!--<xsl:if test="generalization">
                <xsl:attribute name="substitutionGroup">
                    <xsl:value-of select="//packagedElement[@xmi:id=$paid]/@name"/>
                </xsl:attribute>
            </xsl:if>-->
        </xs:element>
        
        <xs:complexType>
            <xsl:attribute name="name"><xsl:value-of select="@name"/><xsl:text>Type</xsl:text></xsl:attribute>
            <xs:complexContent>
                <xs:extension>
                    <xsl:attribute name="base">
                        <xsl:choose>
                          <xsl:when test="generalization">
                               <xsl:choose>
                                    <xsl:when test="//packagedElement[@xmi:id='EAID_ABB8061C_9872_4a25_9083_71EDD5DAA888']/../@name!=$processedNamespace">
                                        <xsl:variable name="tns" select="//packagedElement[@xmi:id='EAID_ABB8061C_9872_4a25_9083_71EDD5DAA888']/../@name"/>
                                        <xsl:value-of select="$properties/SchemaCreationProperties/Namespaces/Namespace[@name=$tns]/@prefix"/>
                                        <xsl:text>:</xsl:text>
                                        <xsl:value-of select="//packagedElement[@xmi:id=$paid]/@name"/>
                                      <xsl:text>test1</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="//packagedElement[@xmi:id=$paid]/@name"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text>Type</xsl:text>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:text>ddic:DDIObjectType</xsl:text>
                          </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xs:sequence>
                        <xsl:apply-templates select="ownedAttribute[@xmi:type='uml:Property']"/>
                    </xs:sequence>
                    <xs:anyAttribute/>
                </xs:extension>
            </xs:complexContent>
        </xs:complexType>
    </xsl:template>
    
    <xsl:template match="ownedAttribute">
        <xsl:choose>
            <xsl:when test="@aggregation or @association">
                <xsl:variable name="paid" select="@association"/>
                <xs:element type="ddic:ReferenceType">
                    <xsl:for-each select="//packagedElement[@xmi:id=$paid]">
                        <xsl:attribute name="name">
                            <xsl:value-of select="ddifunc:to-upper-cc(@name)"/>
                        </xsl:attribute>
                        <xsl:if test="ownedEnd/lowerValue/@value!=''">
                            <xsl:attribute name="minOccurs"><xsl:value-of select="ownedEnd/lowerValue/@value"/></xsl:attribute>
                        </xsl:if>
                        <xsl:if test="ownedEnd/upperValue/@value!=''">
                            <xsl:choose>
                                <xsl:when test="ownedEnd/upperValue/@value='-1'"><xsl:attribute name="maxOccurs"><xsl:text>unbounded</xsl:text></xsl:attribute></xsl:when>
                                <xsl:otherwise><xsl:attribute name="maxOccurs"><xsl:value-of select="ownedEnd/upperValue/@value"/></xsl:attribute></xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:for-each>
                </xs:element>
            </xsl:when>
            <xsl:otherwise>
                <xs:element>
                    <xsl:attribute name="name"><xsl:value-of select="ddifunc:to-upper-cc(@name)"/></xsl:attribute>
                    <xsl:attribute name="type">
                        <xsl:choose>
                            <xsl:when test="contains(type/@xmi:idref, 'string')">
                                <xsl:text>xs:string</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains(type/@xmi:idref, 'integer')">
                                <xsl:text>xs:int</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains(type/@xmi:idref, 'long')">
                                <xsl:text>xs:long</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains(type/@xmi:idref, 'dateTime')">
                                <xsl:text>xs:dateTime</xsl:text>
                            </xsl:when>
                            <xsl:when test="type/@xmi:type = 'String'">
                                <xsl:text>xs:string</xsl:text>
                            </xsl:when>
                            <xsl:when test="type/@xmi:type = 'InternationalisedString'">
                                <xsl:text>ddic:InternationalisedString</xsl:text>
                            </xsl:when>

                          <xsl:when test="type/@xmi:type = 'Boolean'">
                            <xsl:text>xs:boolean</xsl:text>
                          </xsl:when>
                          <xsl:when test="type/@xmi:type = 'Integer'">
                            <xsl:text>xs:int</xsl:text>
                          </xsl:when>
                          <xsl:when test="type/@xmi:type = 'URI'">
                            <xsl:text>xs:anyURI</xsl:text>
                          </xsl:when>
                          
                            <xsl:when test="type/@xmi:type = ''">
                                <xsl:text>ALERT empty type</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>TODO </xsl:text>
                                <xsl:value-of select="type/@xmi:type"/>
                            </xsl:otherwise>
<!-- ToDo more data types -->
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:if test="lowerValue/@value!=''">
                        <xsl:attribute name="minOccurs"><xsl:value-of select="lowerValue/@value"/></xsl:attribute>
                    </xsl:if>
                    <xsl:if test="upperValue/@value!=''">
                        <xsl:choose>
                            <xsl:when test="upperValue/@value='-1'"><xsl:attribute name="maxOccurs"><xsl:text>unbounded</xsl:text></xsl:attribute></xsl:when>
                            <xsl:otherwise><xsl:attribute name="maxOccurs"><xsl:value-of select="upperValue/@value"/></xsl:attribute></xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </xs:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>