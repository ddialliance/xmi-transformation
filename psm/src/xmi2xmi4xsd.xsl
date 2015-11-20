<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:uml="http://www.omg.org/spec/UML/20110701" 
	xmlns:xmi="http://www.omg.org/spec/XMI/20110701" xmlns:ddifunc="ddi:functions"
    exclude-result-prefixes="ddifunc"
    version="2.0">

    <!-- imports -->
    <!--<xsl:import href="../../util/src/support.xsl"/>-->

    <!-- options -->
    <xsl:output method="xml" indent="yes"/>
	
	<xsl:template match="xmi:XMI" mode="ToXMI">
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
			<xsl:apply-templates select="packagedElement[1]" mode="libraryToXMI"/>
			<xsl:copy-of select="packagedElement[2]"/>
		</uml:Model>
	</xsl:template>
	
	<xsl:template match="packagedElement" mode="libraryToXMI">
		<packagedElement>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="packagedElement" mode="packageToXMI"/>
		</packagedElement>
	</xsl:template>
	
	<xsl:template match="packagedElement" mode="packageToXMI">
		<packagedElement>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="packagedElement[@xmi:type='uml:Class' and @isAbstract='true']" mode="abstractClassToXMI"/>
			<xsl:apply-templates select="packagedElement[@xmi:type='uml:Class' and not(@isAbstract='true')]" mode="classToXMI"/>
			<xsl:copy-of select="packagedElement[@xmi:type='uml:Enumeration' or @xmi:type='uml:DataType']"/>
		</packagedElement>
	</xsl:template>
	
	<xsl:template match="packagedElement" mode="absractClassToXMI">
		<xsl:variable name="myName" select="@name"/>
		<xsl:if test="//packagedElement[@xmi:type='uml:Association']/ownedEnd/type/@xmi:idref=$myName">
			<xsl:apply-templates select="." mode="classToXMI"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="packagedElement" mode="classToXMI">
		<xsl:variable name="parentClass" select="generalization/@general"/>
		<xsl:variable name="className" select="@name"/>
		<packagedElement>
			<xsl:copy-of select="@*"/>
			<xsl:copy-of select="generalization"/>
			<xsl:apply-templates select="//packagedElement[@name=$parentClass]" mode="parentClassToXMI">
				<xsl:with-param name="className" select="$className"/>
				<xsl:with-param name="overridden">
					<xsl:for-each select="ownedAttribute">
						<xsl:text>@@</xsl:text>
						<xsl:value-of select="@name"/>
						<xsl:text>@@</xsl:text>
					</xsl:for-each>
				</xsl:with-param>
			</xsl:apply-templates>
			<xsl:copy-of select="ownedAttribute"/>
		</packagedElement>
		<xsl:for-each select="ownedAttribute[@association]">
			<xsl:variable name="associationName" select="@association"/>
			<xsl:apply-templates select="//packagedElement[@xmi:id=$associationName]" mode="associationToXMI">
				<xsl:with-param name="className" select="$className"/>
			</xsl:apply-templates>
		</xsl:for-each>
		<xsl:apply-templates select="//packagedElement[@name=$parentClass]" mode="parentClassAssociationToXMI">
			<xsl:with-param name="className" select="@name"/>
			<xsl:with-param name="overridden">
				<xsl:for-each select="ownedAttribute">
					<xsl:text>@@</xsl:text>
					<xsl:value-of select="@name"/>
					<xsl:text>@@</xsl:text>
				</xsl:for-each>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="packagedElement" mode="parentClassToXMI">
		<xsl:param name="className"/>
		<xsl:param name="overridden"/>
		<xsl:variable name="parentClass" select="generalization/@general"/>
		<xsl:apply-templates select="//packagedElement[@name=$parentClass]" mode="parentClassToXMI">
			<xsl:with-param name="className" select="$className"/>
			<xsl:with-param name="overridden">
				<xsl:value-of select="$overridden"/>
				<xsl:for-each select="ownedAttribute">
					<xsl:text>@@</xsl:text>
					<xsl:value-of select="@name"/>
					<xsl:text>@@</xsl:text>
				</xsl:for-each>
			</xsl:with-param>
		</xsl:apply-templates>
		<xsl:for-each select="ownedAttribute[not(contains($overridden,concat('@',@name,'@')))]">
			<xsl:choose>
				<xsl:when test="@association">
					<ownedAttribute>
						<xsl:copy-of select="@*[name()!='xmi:id' and name()!='association' and name()!='name']"/>
						<xsl:attribute name="xmi:id">
							<xsl:value-of select="$className"/>
							<xsl:text>_</xsl:text>
							<xsl:value-of select="substring-after(@xmi:id, '_')"/>
						</xsl:attribute>
						<xsl:attribute name="association">
							<xsl:value-of select="$className"/>
							<xsl:text>_</xsl:text>
							<xsl:value-of select="substring-after(@association, '_')"/>
						</xsl:attribute>
						<xsl:attribute name="name">
							<xsl:value-of select="$className"/>
						</xsl:attribute>
						<xsl:copy-of select="type"/>
						<lowerValue>
							<xsl:copy-of select="lowerValue/@*[name()!='xmi:id']"/>
							<xsl:attribute name="xmi:id">
								<xsl:value-of select="$className"/>
								<xsl:text>_</xsl:text>
								<xsl:value-of select="substring-after(lowerValue/@xmi:id, '_')"/>
							</xsl:attribute>
						</lowerValue>
						<upperValue>
							<xsl:copy-of select="upperValue/@*[name()!='xmi:id']"/>
							<xsl:attribute name="xmi:id">
								<xsl:value-of select="$className"/>
								<xsl:text>_</xsl:text>
								<xsl:value-of select="substring-after(upperValue/@xmi:id, '_')"/>
							</xsl:attribute>
						</upperValue>
					</ownedAttribute>
				</xsl:when>
				<xsl:otherwise>
					<ownedAttribute>
						<xsl:copy-of select="@*[name()!='xmi:id']"/>
						<xsl:attribute name="xmi:id">
							<xsl:value-of select="$className"/>
							<xsl:text>_</xsl:text>
							<xsl:value-of select="substring-after(@xmi:id, '_')"/>
						</xsl:attribute>
						<xsl:copy-of select="type"/>
						<xsl:copy-of select="lowerValue"/>
						<xsl:copy-of select="upperValue"/>
					</ownedAttribute>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="packagedElement" mode="parentClassAssociationToXMI">
		<xsl:param name="className"/>
		<xsl:param name="overridden"/>
		<xsl:variable name="parentClass" select="generalization/@general"/>
		<xsl:for-each select="ownedAttribute[@association and not(contains($overridden,concat('@',@name,'@')))]">
			<xsl:variable name="associationName" select="@association"/>
			<xsl:apply-templates select="//packagedElement[@xmi:id=$associationName]" mode="associationToXMI">
				<xsl:with-param name="className" select="$className"/>
			</xsl:apply-templates>
		</xsl:for-each>
		<xsl:apply-templates select="//packagedElement[@name=$parentClass]" mode="parentClassAssociationToXMI">
			<xsl:with-param name="className" select="$className"/>
			<xsl:with-param name="overridden">
				<xsl:for-each select="ownedAttribute">
					<xsl:value-of select="$overridden"/>
					<xsl:text>@@</xsl:text>
					<xsl:value-of select="@name"/>
					<xsl:text>@@</xsl:text>
				</xsl:for-each>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="packagedElement" mode="associationToXMI">
		<xsl:param name="className"/>
		<packagedElement>
			<xsl:copy-of select="@*[name()!='xmi:id']"/>
			<xsl:attribute name="xmi:id">
				<xsl:value-of select="$className"/>
				<xsl:text>_</xsl:text>
				<xsl:value-of select="substring-after(@xmi:id, '_')"/>
			</xsl:attribute>
			<xsl:for-each select="memberEnd">
				<memberEnd>
					<xsl:attribute name="xmi:idref">
						<xsl:value-of select="$className"/>
						<xsl:text>_</xsl:text>
						<xsl:value-of select="substring-after(@xmi:idref, '_')"/>
					</xsl:attribute>
				</memberEnd>
			</xsl:for-each>
			<ownedEnd>
				<xsl:copy-of select="ownedEnd/@*[name()!='xmi:id' and name()!='association']"/>
				<xsl:attribute name="xmi:id">
					<xsl:value-of select="$className"/>
					<xsl:text>_</xsl:text>
					<xsl:value-of select="substring-after(ownedEnd/@xmi:id, '_')"/>
				</xsl:attribute>
				<xsl:attribute name="association">
					<xsl:value-of select="$className"/>
					<xsl:text>_</xsl:text>
					<xsl:value-of select="substring-after(ownedEnd/@association, '_')"/>
				</xsl:attribute>
				<type>
					<xsl:attribute name="xmi:idref"><xsl:value-of select="$className"/></xsl:attribute>
				</type>
				<lowerValue>
					<xsl:copy-of select="lowerValue/@*[name()!='xmi:id']"/>
					<xsl:attribute name="xmi:id">
						<xsl:value-of select="$className"/>
						<xsl:text>_</xsl:text>
						<xsl:value-of select="substring-after(lowerValue/@xmi:id, '_')"/>
					</xsl:attribute>
				</lowerValue>
				<upperValue>
					<xsl:copy-of select="upperValue/@*[name()!='xmi:id']"/>
					<xsl:attribute name="xmi:id">
						<xsl:value-of select="$className"/>
						<xsl:text>_</xsl:text>
						<xsl:value-of select="substring-after(upperValue/@xmi:id, '_')"/>
					</xsl:attribute>
				</upperValue>
			</ownedEnd>
		</packagedElement>
	</xsl:template>
		
	
	<xsl:template match="xmi:Extension">
		<xmi:Extension>
			<xsl:copy-of select="@*"/>
			<elements>
				<xsl:copy-of select="elements/element[@xmi:type='uml:Package']"/>
				<xsl:apply-templates select="//packagedElement[@xmi:type='uml:Class']" mode="classElementToXMI"/>
			</elements>
			<connectors>
				<!-- left out, just for drawing -->
			</connectors>
			<diagrams>
				<!-- left out, just for drawing -->
			</diagrams>
		</xmi:Extension>
	</xsl:template>
	
	<xsl:template match="packagedElement" mode="classElementToXMI">
		<xsl:variable name="myName" select="@name"/>
		<xsl:variable name="parentClass" select="generalization/@general"/>
		<xsl:choose>
			<xsl:when test="@isAbstract='true'">
				<xsl:if test="//packagedElement[@xmi:type='uml:Association']/ownedEnd/type/@xmi:idref=$myName">
					<element>
						<xsl:apply-templates select="/xmi:XMI/xmi:Extension/elements/element[@name=$myName]" mode="classElementToXMI"/>
						<attributes>
							<xsl:apply-templates select="//packagedElement[@name=$parentClass]" mode="parentClassElementToXMI">
								<xsl:with-param name="class" select="."/>
								<xsl:with-param name="overridden">
									<xsl:for-each select="ownedAttribute">
										<xsl:text>@@</xsl:text>
										<xsl:value-of select="@name"/>
										<xsl:text>@@</xsl:text>
									</xsl:for-each>
								</xsl:with-param>
							</xsl:apply-templates>
							<xsl:apply-templates select="/xmi:XMI/xmi:Extension/elements/element[@name=$myName]/attributes/attribute" mode="classAttributeToXMI">
								<xsl:with-param name="class" select="."/>
							</xsl:apply-templates>
						</attributes>
					</element>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<element>
					<xsl:apply-templates select="/xmi:XMI/xmi:Extension/elements/element[@name=$myName]" mode="classElementToXMI"/>
					<attributes>
						<xsl:apply-templates select="//packagedElement[@name=$parentClass]" mode="parentClassElementToXMI">
							<xsl:with-param name="class" select="."/>
							<xsl:with-param name="overridden">
								<xsl:for-each select="ownedAttribute">
									<xsl:text>@@</xsl:text>
									<xsl:value-of select="@name"/>
									<xsl:text>@@</xsl:text>
								</xsl:for-each>
							</xsl:with-param>
						</xsl:apply-templates>
						<xsl:apply-templates select="/xmi:XMI/xmi:Extension/elements/element[@name=$myName]/attributes/attribute" mode="classAttributeToXMI">
							<xsl:with-param name="class" select="."/>
						</xsl:apply-templates>
					</attributes>
				</element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="packagedElement" mode="parentClassElementToXMI">
		<xsl:param name="class"/>
		<xsl:param name="overridden"/>
		<xsl:variable name="myName" select="@name"/>
		<xsl:variable name="parentClass" select="generalization/@general"/>
		<xsl:apply-templates select="//packagedElement[@name=$parentClass]" mode="parentClassElementToXMI">
			<xsl:with-param name="class" select="$class"/>
			<xsl:with-param name="overridden">
				<xsl:for-each select="ownedAttribute">
					<xsl:value-of select="$overridden"/>
					<xsl:text>@@</xsl:text>
					<xsl:value-of select="@name"/>
					<xsl:text>@@</xsl:text>
				</xsl:for-each>
			</xsl:with-param>
		</xsl:apply-templates>
		<xsl:apply-templates select="/xmi:XMI/xmi:Extension/elements/element[@name=$myName]/attributes/attribute" mode="classAttributeToXMI">
			<xsl:with-param name="class" select="$class"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="element" mode="classElementToXMI">
		<xsl:copy-of select="@*"/>
		<xsl:copy-of select="model"/>
		<xsl:copy-of select="properties"/>
		<xsl:copy-of select="extendedProperties"/>
		<xsl:copy-of select="code"/>
	</xsl:template>
	
	<xsl:template match="attribute" mode="classAttributeToXMI">
		<xsl:param name="class"/>
		<attribute>
			<xsl:copy-of select="@scope"/>
			<xsl:copy-of select="@name"/>
			<xsl:attribute name="xmi:idref">
				<xsl:value-of select="$class/@name"/>
				<xsl:text>_</xsl:text>
				<xsl:value-of select="substring-after(@xmi:idref,'_')"/>
			</xsl:attribute>
			<xsl:copy-of select="*"/>
		</attribute>
	</xsl:template>
	
</xsl:stylesheet>