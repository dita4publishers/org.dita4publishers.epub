<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:df="http://dita2indesign.org/dita/functions"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:opf="http://www.idpf.org/2007/opf"
  xmlns:epubtrans="urn:d4p:epubtranstype"
  xmlns="http://www.idpf.org/2007/opf"
  exclude-result-prefixes="xs df relpath epubtrans"
  version="3.0">
    
  <!-- Extensions for DITA Bookmap map type modules in
  different contexts -->
  
 
  <!-- FIXME: Add rules for other topicrefs -->
  
  <!-- TOC (.ncx) generation context -->
  
  <xsl:template mode="nav-point-title" match="*[df:class(., 'bookmap/toc')]" priority="20">
    <xsl:call-template name="getString">
        <xsl:with-param name="stringName" select="'Contents'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template 
    mode="generate-toc"
    match="*[df:class(., 'bookmap/toc')]" 
    priority="20" 
    >
    <xsl:call-template name="construct_navpoint">
      <xsl:with-param name="targetUri" as="xs:string"
        select="concat('toc_', generate-id(.), $outext)"
      />
    </xsl:call-template>    
  </xsl:template>
  
  
  <!-- OPF (.opf) generation context -->
  
  <xsl:template mode="include-topicref-in-spine include-topicref-in-manifest" 
    match="*[df:class(., 'bookmap/toc')] | 
    *[df:class(., 'bookmap/figurelist')] | 
    *[df:class(., 'bookmap/tablelist')]" 
    priority="10">
    <xsl:sequence select="true()"/>    
  </xsl:template>
  
  <xsl:template mode="epubtrans:manifest manifest" match="*[df:class(., 'bookmap/toc')]">
    <xsl:variable name="targetUri" as="xs:string"
      select="concat('toc_', generate-id(.), $outext)"
    />
    <item id="{generate-id()}" href="{$targetUri}"
      media-type="application/xhtml+xml">
      <xsl:if test="epubtrans:isScripted(.)">
        <xsl:attribute name="properties" select="'scripted'"/>          
      </xsl:if>      
    </item>
  </xsl:template>
  
  <xsl:template mode="epubtrans:manifest manifest" match="*[df:class(., 'bookmap/figurelist')]">
    <xsl:variable name="targetUri" as="xs:string"
      select="concat('list-of-figures_', generate-id(.), $outext)"
    />
    <item id="{generate-id()}" href="{$targetUri}"
      media-type="application/xhtml+xml">
      <xsl:if test="epubtrans:isScripted(.)">
        <xsl:attribute name="properties" select="'scripted'"/>          
      </xsl:if>
    </item>    
  </xsl:template>
  
  <xsl:template mode="epubtrans:manifest manifest" match="*[df:class(., 'bookmap/tablelist')]">
    <xsl:variable name="targetUri" as="xs:string"
      select="concat('list-of-tables_', generate-id(.), $outext)"
    />
    <item id="{generate-id()}" href="{$targetUri}"
      media-type="application/xhtml+xml">
      <xsl:if test="epubtrans:isScripted(.)">
        <xsl:attribute name="properties" select="'scripted'"/>          
      </xsl:if>
    </item>    
  </xsl:template>
  
  <xsl:template mode="generate-book-lists" match="*[df:class(., 'bookmap/figurelist')]" priority="10">
    <xsl:param name="collected-data" as="element()*" tunnel="yes"/>
    <xsl:call-template name="generate-figure-list-html-doc">
      <xsl:with-param name="collected-data" select="$collected-data" as="element()"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template mode="generate-book-lists" match="*[df:class(., 'bookmap/tablelist')]" priority="10">
    <xsl:param name="collected-data" as="element()*" tunnel="yes"/>
    <xsl:call-template name="generate-table-list-html-doc">
      <xsl:with-param name="collected-data" select="$collected-data" as="element()"/>      
    </xsl:call-template>        
  </xsl:template>
  
  <xsl:template mode="spine" 
    match="*[df:class(., 'bookmap/toc')][not(@href)] |
    *[df:class(., 'bookmap/figurelist')] |
    *[df:class(., 'bookmap/tablelist')]" 
    priority="10">
    <itemref idref="{generate-id()}"/>    
  </xsl:template>
  
  <xsl:template mode="guide" match="*[df:class(., 'bookmap/toc')][not(@href)]" priority="10">
    <xsl:variable name="targetUri" as="xs:string"
      select="concat('toc_', generate-id(.), $outext)"
    />
    <reference type="toc"  href="{$targetUri}"/>    
  </xsl:template>
  
  <xsl:template mode="generate-book-lists" match="*[df:class(., 'bookmap/toc')][not(@href)]" priority="10">
    <xsl:if test="$debugBoolean">
      <xsl:message> + [DEBUG] generate-book-lists: bookmap/toc</xsl:message>
    </xsl:if>
    <xsl:variable name="htmlFilename" as="xs:string"
      select="concat('toc_', generate-id(.), $outext)"
    />
    <xsl:variable name="resultUri" as="xs:string"
      select="relpath:newFile($outdir, $htmlFilename)"
    />
    <xsl:apply-templates mode="generate-html-toc"
      select="ancestor::*[df:class(., 'map/map')]"
      >
      <xsl:with-param name="resultUri" select="$resultUri"/>
    </xsl:apply-templates>
  </xsl:template>
  
  
  
  
</xsl:stylesheet>
