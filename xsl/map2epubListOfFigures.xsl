<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:df="http://dita2indesign.org/dita/functions" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:htmlutil="http://dita4publishers.org/functions/htmlutil"
  xmlns:index-terms="http://dita4publishers.org/index-terms" xmlns:local="urn:functions:local"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:enum="http://dita4publishers.org/enumerables"
  xmlns:epubtrans="urn:d4p:epubtranstype"
  exclude-result-prefixes="#all"
  version="3.0">
    
  <xsl:template match="/" mode="generate-list-of-figures-html-toc">
    <xsl:apply-templates mode="#current"/>
  </xsl:template> 
  
  <xsl:template match="*[df:class(., 'map/map')]" 
    mode="generate-list-of-figures-html-toc">
    <xsl:param name="collected-data" as="element()*" tunnel="yes"/>
    <xsl:apply-templates mode="#current"
      select="$collected-data/enum:enumerables//*[df:class(., 'topic/fig')][enum:title]"/>
  </xsl:template>
  
  <xsl:template mode="generate-list-of-figures-html-toc" 
                match="*[df:class(., 'topic/fig')]">
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>
    <xsl:param name="topicref" as="element()?" tunnel="yes"/>

    <xsl:variable name="sourceUri" as="xs:string" select="@docUri"/>
    <xsl:variable name="rootTopic" select="document($sourceUri)" as="document-node()?"/>
    <xsl:variable name="targetUri"
      select="htmlutil:getTopicResultUrl2($outdir, $rootTopic, $topicref, $rootMapDocUrl)"
      as="xs:string"/>
    <xsl:variable name="relativeUri" select="relpath:getRelativePath($outdir, $targetUri)"
      as="xs:string"/>
    <xsl:variable name="enumeratedElement" 
      select="key('elementsByXtrc', string(@xtrc), root($rootTopic))" 
      as="element()?"/>
    <xsl:variable name="containingTopic" as="element()"
      select="df:getContainingTopic($enumeratedElement)"
    />
    <li class="html-toc-entry html-toc-entry_1">
      <!-- FIXME: Here we're replicating ID construction logic implemented elsewhere in the Toolkit.
           This is of course fragile. -->
      <span class="html-toc-entry-text html-toc-entry-text_1"
        ><a href="{$relativeUri}{if (@origId) 
          then concat('#', $containingTopic/@id, '__', @origId) 
          else concat('#', df:generate-dita-id($enumeratedElement))}"
          >
          <xsl:if test="$contenttarget">
            <xsl:attribute name="target" select="$contenttarget"/>
          </xsl:if>
          <!-- Generate a number, if any -->
          <xsl:apply-templates select="." mode="enumeration"/> 
          <xsl:apply-templates 
            select="$enumeratedElement/*[df:class(., 'topic/title')]" 
            mode="#current"/></a></span>
    </li>    
  </xsl:template>
  
  
  <xsl:template match="*" mode="generate-list-of-figures-html-toc" priority="-1">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template mode="generate-list-of-figures-html-toc" match="text()"/>
  
  <xsl:template mode="generate-list-of-figures-html-toc" match="*[df:class(., 'topic/title')]">
    <xsl:variable name="html" as="node()*">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:apply-templates select="$html" mode="html2xhtml"/>
  </xsl:template>
  
  <xsl:template name="generate-figure-list-html-doc">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="collected-data" as="element()*"/>
    <xsl:variable name="resultUri"
      select="relpath:newFile($outdir, concat('list-of-figures_', generate-id(.), $outext))" 
      as="xs:string"
    />
    <xsl:variable name="lof-title" as="node()*">
      <xsl:text>List of Figures</xsl:text><!-- FIXME: Get this string from string config -->
    </xsl:variable>
    
    <xsl:message> + [INFO] Generating list of figures as "<xsl:sequence select="$resultUri"/>"</xsl:message>
    
    <xsl:result-document href="{$resultUri}"
      format="html5">
      <html>
        <head>                   
          <title><xsl:sequence select="$lof-title"/></title>
          <xsl:call-template name="constructToCStyle">
            <xsl:with-param name="resultUri" as="xs:string" tunnel="yes" select="$resultUri"/>
          </xsl:call-template>
          <xsl:call-template name="epubtrans:constructJavaScriptReferences">
            <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
            <xsl:with-param name="resultUri" as="xs:string" select="$resultUri"/>
          </xsl:call-template>
        </head>
        <body class="toc-list-of-figures html-toc">
          <h2 class="toc-title"><xsl:sequence select="$lof-title"/></h2>
          <ul  class="html-toc html-toc_1 list-of-figures">
            <xsl:apply-templates select="root(.)" mode="generate-list-of-figures-html-toc">
              <xsl:with-param 
                name="collected-data" 
                select="$collected-data" 
                tunnel="yes" 
                as="element()"
              />              
            </xsl:apply-templates>
          </ul>
        </body>
      </html>
    </xsl:result-document>
    
  </xsl:template>
  
</xsl:stylesheet>