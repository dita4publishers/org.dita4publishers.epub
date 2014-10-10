<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
                xmlns:df="http://dita2indesign.org/dita/functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:relpath="http://dita2indesign/functions/relpath"
                xmlns:htmlutil="http://dita4publishers.org/functions/htmlutil"
                xmlns:index-terms="http://dita4publishers.org/index-terms"
                xmlns:glossdata="http://dita4publishers.org/glossdata"
                xmlns:mapdriven="http://dita4publishers.org/mapdriven"
                xmlns:enum="http://dita4publishers.org/enumerables"
                xmlns="http://www.daisy.org/z3986/2005/ncx/"
                xmlns:local="urn:functions:local"
                xmlns:epub="urn:d4p:epubtranstype"
                exclude-result-prefixes="local xs df xsl relpath htmlutil index-terms epub"
  >
  <!-- ============================================================================= 
    
       Generate the <nav> structure for EPUB3
       
       Implements mode "epub:generate-nav"
       
       NOTE: Mode generate-toc is for the EPUB2 toc.ncx file. 
       
       ============================================================================= -->
  
  <xsl:output indent="yes" name="ncx" method="xml"/>
  
  <xsl:template match="*[df:class(., 'map/map')]" mode="epub:generate-nav">
    <xsl:param name="collected-data" as="element()" tunnel="yes"/>
    <xsl:variable name="pubTitle" as="xs:string*">
      <xsl:apply-templates select="*[df:class(., 'topic/title')] | @title" mode="pubtitle"/>
    </xsl:variable>           
    <xsl:variable name="resultUri" 
      select="relpath:newFile($outdir, 'nav.xhtml')" 
      as="xs:string"/>
    <xsl:message> + [INFO] Constructing nav structure...</xsl:message>
    
    <xsl:message> + [INFO] Generating EPUB3 Nav document "<xsl:sequence select="$resultUri"/>"...</xsl:message>
    
    <xsl:result-document href="{$resultUri}" format="html5">
      <html 
        xmlns="http://www.w3.org/1999/xhtml" 
        xmlns:epub="http://www.idpf.org/2007/ops" 
        >
      	<head>
      		<meta charset="utf-8" />
      		<!-- FIXME: May need to generate appropriate CSS references here -->
      	</head>
      	<body>
          <nav epub:type="toc" id="toc">
            <!-- FIXME: get from variable: -->
            <h1 class="title">Table of Contents</h1>
            <!-- NOTE: We're using the EPUB2 HTML ToC generation code here.
              
                 In EPUB3, the nav document can also serve as the content ToC,
                 whereas for EPUB2 there is always a toc.ncx in addition to any
                 HTML ToC.
                        
            -->
            <ol>
              <xsl:apply-templates select="*[df:class(., 'map/topicref')]" mode="generate-html-toc">
                <xsl:with-param name="tocDepth" as="xs:integer" tunnel="yes" select="1"/>
                <xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>
              </xsl:apply-templates>
            </ol>
          </nav>
      	  <!-- NOTE: Repeating the collected-data parameter here even though it's not necessary
      	             just to make it clear to readers of the code that the parameter is available
      	             to down-stream templates.
      	    -->
      	  <xsl:apply-templates select="." mode="epub:generate-landmarks-nav">
      	    <xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>
      	  </xsl:apply-templates>
      	  <xsl:apply-templates select="." mode="epub:generate-pagelist-nav">
      	    <xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>
      	  </xsl:apply-templates>
      	  <xsl:apply-templates select="." mode="epub:generate-custom-nav">
      	    <xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>
      	  </xsl:apply-templates>
      	</body>
      </html>
    </xsl:result-document>  
    <xsl:message> + [INFO] EPUB3 Nav generation done.</xsl:message>
  </xsl:template>
  
  <xsl:template mode="epub:generate-landmarks-nav" match="*[df:class(., 'map/map')]">
    <!-- Default: No landmarks nav. 
      
      The landmarks nav section should be e.g., 
      
      <nav epub:type="landmarks">
          <h2>Guide</h2>
          <ol>
              <li><a epub:type="toc" href="#toc">Table of Contents</a></li>
              <li><a epub:type="loi" href="content.html#loi">List of Illustrations</a></li>
              <li><a epub:type="bodymatter" href="content.html#bodymatter">Start of Content</a></li>
          </ol>
      </nav>
      -->
  </xsl:template>
  
  <xsl:template mode="epub:generate-pagelist-nav" match="*[df:class(., 'map/map')]">
    <!-- Default: No landmarks nav. 
      
      The landmarks nav section should be e.g., 
      
      <nav epub:type="page-list">
        <h2>Page List</h2>
        <ol>
        	<li><a href="testdoc-001.xhtml#p110">110</a></li>
        </ol>
			</nav>
      -->
  </xsl:template>
  
  <xsl:template mode="epub:generate-custom-nav" match="*[df:class(., 'map/map')]">
    <!-- Mode for generating arbitrary navigation structures. See 
      http://www.idpf.org/epub/301/spec/epub-contentdocs.html#sec-xhtml-nav-def-types-pagelist
      
      Extensions can hook this mode to generate whatever additional navigation
      structures they want.
      -->
  </xsl:template>
  
  <xsl:template mode="epub:generate-nav" match="*[df:class(., 'topic/title')][not(@toc = 'no')]"/>

  <!-- Convert each topicref to a ToC entry. -->
  <xsl:template match="*[df:isTopicRef(.)][not(@toc = 'no')]" mode="epub:generate-nav">
    <xsl:param name="tocDepth" as="xs:integer" tunnel="yes" select="0"/>
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>

    <xsl:if test="$tocDepth le $maxTocDepthInt">
      <xsl:variable name="topic" select="df:resolveTopicRef(.)" as="element()*"/>
      <xsl:choose>
        <xsl:when test="not($topic)">
          <xsl:message> + [WARNING] epub:generate-nav: Failed to resolve topic reference to href
              "<xsl:sequence select="string(@href)"/>"</xsl:message>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="targetUri"
            select="htmlutil:getTopicResultUrl($outdir, root($topic), $rootMapDocUrl)"
            as="xs:string"/>
          <xsl:variable name="relativeUri" select="relpath:getRelativePath($outdir, $targetUri)"
            as="xs:string"/>
          <xsl:variable name="enumeration" as="xs:string?">
            <xsl:apply-templates select="." mode="enumeration"/>
          </xsl:variable>
          <xsl:variable name="self" select="generate-id(.)" as="xs:string"/>

          <!-- Use UL for navigation structure -->

          <li>
            <a href="{$relativeUri}">
              <!-- target="{$contenttarget}" -->
              <xsl:if test="$enumeration and $enumeration != ''">
                <span class="enumeration enumeration{$tocDepth}">
                  <xsl:sequence select="$enumeration"/>
                </span>
              </xsl:if>
              <xsl:apply-templates select="." mode="nav-point-title"/>
            </a>
            <xsl:if test="$topic/*[df:class(., 'topic/topic')], *[df:class(., 'map/topicref')]">
              <xsl:variable name="listItems" as="node()*">
                <!-- Any subordinate topics in the currently-referenced topic are
              reflected in the ToC before any subordinate topicrefs.
            -->
                <xsl:apply-templates mode="#current"
                  select="$topic/*[df:class(., 'topic/topic')], *[df:class(., 'map/topicref')]">
                  <xsl:with-param name="tocDepth" as="xs:integer" tunnel="yes"
                    select="$tocDepth + 1"/>
                </xsl:apply-templates>
              </xsl:variable>
              <xsl:if test="$listItems">
                <ul>
                  <xsl:sequence select="$listItems"/>
                </ul>
              </xsl:if>
            </xsl:if>
          </li>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[df:isTopicGroup(.)]" priority="20" mode="epub:generate-nav">
    <xsl:apply-templates select="*[df:class(., 'map/topicref')]" mode="#current"/>
  </xsl:template>

  <xsl:template match="*[df:class(., 'topic/topic')]" mode="epub:generate-nav">
    <!-- Non-root topics generate ToC entries if they are within the ToC depth -->
    <xsl:param name="tocDepth" as="xs:integer" tunnel="yes" select="0"/>
    <xsl:if test="$tocDepth le $maxTocDepthInt">
      <!-- FIXME: Handle nested topics here. -->
    </xsl:if>
  </xsl:template>

  <xsl:template mode="#all"
    match="*[df:class(., 'map/topicref') and (@processing-role = 'resource-only')]" priority="30"/>


  <!-- topichead elements get a navPoint, but don't actually point to
       anything.  Same with topicref that has no @href. -->
  <xsl:template match="*[df:isTopicHead(.)][not(@toc = 'no')]" mode="epub:generate-nav">
    <xsl:param name="tocDepth" as="xs:integer" tunnel="yes" select="0"/>

    <xsl:if test="$tocDepth le $maxTocDepthInt">
      <xsl:variable name="navPointId" as="xs:string" select="generate-id(.)"/>
      <li id="{$navPointId}" class="topichead">
        <span>
          <xsl:sequence select="df:getNavtitleForTopicref(.)"/>
        </span>
        <xsl:variable name="listItems" as="node()*">
          <xsl:apply-templates select="*[df:class(., 'map/topicref')]" mode="#current">
            <xsl:with-param name="tocDepth" as="xs:integer" tunnel="yes" select="$tocDepth + 1"/>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:if test="$listItems">
          <ul>
            <xsl:sequence select="$listItems"/>
          </ul>
        </xsl:if>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[df:class(., 'topic/tm')]" mode="epub:generate-nav">
    <xsl:apply-templates mode="#current"/>
    <xsl:choose>
      <xsl:when test="@type = 'reg'">
        <xsl:text>[reg]</xsl:text>
      </xsl:when>
      <xsl:when test="@type = 'sm'">
        <xsl:text>[sm]</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>[tm]</xsl:text>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template
    match="
    *[df:class(., 'topic/topicmeta')] |
    *[df:class(., 'map/navtitle')] |
    *[df:class(., 'topic/ph')] |
    *[df:class(., 'topic/cite')] |
    *[df:class(., 'topic/image')] |
    *[df:class(., 'topic/keyword')] |
    *[df:class(., 'topic/term')]
    "
    mode="epub:generate-nav">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="*[df:class(., 'topic/title')]//text()" mode="epub:generate-nav">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="text()" mode="epub:generate-nav"/>

  <xsl:template match="@*|node()" mode="fix-navigation-href">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="fix-navigation-href"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="li" mode="fix-navigation-href">
    <xsl:param name="topicRelativeUri" as="xs:string" select="''" tunnel="yes"/>
    <xsl:variable name="isActiveTrail" select="descendant::*[contains(@href, $topicRelativeUri)]"/>
    <xsl:variable name="hasChild" select="descendant::li"/>

    <xsl:variable name="hasChildClass">
      <xsl:choose>
        <xsl:when test="$hasChild">
          <xsl:value-of select="' collapsible '"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="' no-child '"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <li>
      <xsl:attribute name="class" select="@class"/>
      <xsl:if test="text()[1]">
        <span class="navtitle">
          <xsl:value-of select="text()[1]" />
        </span>
      </xsl:if>
      <xsl:apply-templates select="*" mode="fix-navigation-href"/>
    </li>
  </xsl:template>


  <xsl:template match="a" mode="fix-navigation-href">
   <xsl:param name="topicRelativeUri" as="xs:string" select="''" tunnel="yes"/>
    <xsl:param name="relativePath" as="xs:string" select="''" tunnel="yes"/>

   <xsl:variable name="isSelected" select="@href=$topicRelativeUri"/>

    <xsl:variable name="prefix">
      <xsl:choose>
        <xsl:when test="substring(@href, 1, 1) = '#'">
          <xsl:value-of select="''"/>
        </xsl:when>
        <xsl:when test="substring(@href, 1, 1) = '/'">
          <xsl:value-of select="''"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$relativePath"/>
        </xsl:otherwise>

      </xsl:choose>
    </xsl:variable>
  <a>
    <xsl:if test="$isSelected">
      <xsl:attribute name="class" select="'selected'" />
    </xsl:if>
      <xsl:attribute name="href" select="concat($prefix, @href)"/>
      <xsl:sequence select="node()" />
    </a>
  </xsl:template>

  <xsl:template match="mapdriven:collected-data" mode="epub:generate-nav">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="enum:enumerables" mode="epub:generate-nav">
    <!-- Nothing to do with enumerables in this context -->
  </xsl:template>

  <xsl:template match="glossdata:glossary-entries" mode="epub:generate-nav">
    <xsl:message> + [INFO] EPUB3 nav generation: glossary entry processing not yet
      implemented.</xsl:message>
  </xsl:template>

</xsl:stylesheet>
