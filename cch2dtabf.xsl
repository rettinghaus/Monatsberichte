<?xml version="1.0"?>
<xsl:stylesheet xmlns:edate="http://exslt.org/dates-and-times" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei edate" version="1.0">
  <!--

       Transform TEI P4 to DTAbf

       Klaus Rettinghaus

  -->
  <xsl:output method="xml" encoding="utf-8" cdata-section-elements="tei:eg" omit-xml-declaration="no" />

  <xsl:variable name="processor">
    <xsl:value-of select="system-property('xsl:vendor')" />
  </xsl:variable>

  <xsl:variable name="today">
    <xsl:choose>
      <xsl:when test="function-available('edate:date-time')">
        <xsl:value-of select="edate:date-time()" />
      </xsl:when>
      <xsl:when test="contains($processor,'SAXON')">
        <xsl:value-of select="Date:toString(Date:new())" xmlns:Date="/java.util.Date" />
      </xsl:when>
      <xsl:otherwise>0000-00-00</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="uc">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
  <xsl:variable name="lc">abcdefghijklmnopqrstuvwxyz</xsl:variable>

  <xsl:template match="*">
    <xsl:choose>
      <xsl:when test="namespace-uri()=''">
        <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="{local-name(.)}">
          <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()" />
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()" />
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="@*|processing-instruction()|comment()">
    <xsl:copy/>
  </xsl:template>


  <xsl:template match="text()">
    <xsl:value-of select="." />
  </xsl:template>


  <xsl:template match="TEI.2">
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()" />
    </TEI>
  </xsl:template>

  <xsl:template match="xref">
    <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="ref">
      <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="language">
    <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="language">
      <xsl:if test="@id">
        <xsl:attribute name="ident">
          <xsl:value-of select="@id" />
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="*|processing-instruction()|comment()|text()" />
    </xsl:element>
  </xsl:template>

  <!-- attributes changed name -->

  <xsl:template match="@url">
    <xsl:attribute name="target">
      <xsl:value-of select="." />
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@id">
    <xsl:choose>
      <xsl:when test="parent::lang">
        <xsl:attribute name="ident">
          <xsl:value-of select="." />
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="xml:id">
          <xsl:value-of select="." />
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="@lang">
    <xsl:attribute name="xml:lang">
      <xsl:value-of select="." />
    </xsl:attribute>
  </xsl:template>

  <!-- all pointing attributes preceded by # -->

  <xsl:template match="variantEncoding/@location">
    <xsl:copy-of select="." />
  </xsl:template>

  <xsl:template match="@ana|@active|@adj|@adjFrom|@adjTo|@children|@children|@class|@code|@code|@copyOf|@corresp|@decls|@domains|@end|@exclude|@fVal|@feats|@follow|@from|@hand|@inst|@langKey|@location|@mergedin|@new|@next|@old|@origin|@otherLangs|@parent|@passive|@perf|@prev|@render|@resp|@sameAs|@scheme|@script|@select|@since|@start|@synch|@target|@targetEnd|@to|@to|@value|@value|@who|@wit">
    <xsl:attribute name="{name(.)}">
      <xsl:call-template name="splitter">
        <xsl:with-param name="val">
          <xsl:value-of select="." />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:attribute>
  </xsl:template>


  <xsl:template name="splitter">
    <xsl:param name="val" />
    <xsl:choose>
      <xsl:when test="contains($val,' ')">
        <xsl:text>#</xsl:text>
        <xsl:value-of select="substring-before($val,' ')" />
        <xsl:text> </xsl:text>
        <xsl:call-template name="splitter">
          <xsl:with-param name="val">
            <xsl:value-of select="substring-after($val,' ')" />
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>#</xsl:text>
        <xsl:value-of select="$val" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- fool around with selected elements -->

  <xsl:template match="editionStmt/editor">
    <respStmt xmlns="http://www.tei-c.org/ns/1.0">
      <resp>
        <xsl:value-of select="@role" />
      </resp>
      <name>
        <xsl:apply-templates/>
      </name>
    </respStmt>
  </xsl:template>

  <!-- header -->

  <xsl:template match="teiHeader">
    <teiHeader xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" />
    </teiHeader>
  </xsl:template>

  <xsl:template match="publicationStmt">
    <publicationStmt xmlns="http://www.tei-c.org/ns/1.0">
      <publisher>
        <persName ref="http://d-nb.info/gnd/140541624">
          <surname>Rettinghaus</surname>
          <forename>Klaus</forename>
        </persName>
      </publisher>
      <pubPlace>Leipzig</pubPlace>
      <date type="publication">
        <xsl:value-of select="$today" xmlns="http://www.tei-c.org/ns/1.0" />
      </date>
      <availability>
        <licence target="https://creativecommons.org/licenses/by/4.0/deed.de">
          <p>Distributed under the Creative Commons Attribution 4.0 International License.</p>
        </licence>
      </availability>
    </publicationStmt>
  </xsl:template>

  <xsl:template match="sourceDesc">
    <sourceDesc xmlns="http://www.tei-c.org/ns/1.0">
      <bibl>Musikalisch-literarischer Monatsbericht über neue Musikalien, musikalische Schriften und Abbildungen</bibl>
    </sourceDesc>
  </xsl:template>

  <xsl:template match="revisionDesc">
    <revisionDesc xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" />
      <change>
        <date>
          <xsl:value-of select="$today" />
        </date>
        <name>Rettinghaus</name>
        Converted to TEI P5 XML.
      </change>
    </revisionDesc>
  </xsl:template>

  <!-- space does not have @extent any more -->
  <xsl:template match="space/@extent">
    <xsl:attribute name="quantity">
      <xsl:value-of select="." />
    </xsl:attribute>
  </xsl:template>

  <!-- tagsDecl has a compulsory namespace child now -->
  <xsl:template match="tagsDecl">
    <xsl:if test="*">
      <tagsDecl xmlns="http://www.tei-c.org/ns/1.0">
        <namespace name="http://www.tei-c.org/ns/1.0">
          <xsl:apply-templates select="*|comment()|processing-instruction" />
        </namespace>
      </tagsDecl>
    </xsl:if>
  </xsl:template>

  <!-- orgTitle inside orgName? redundant -->
  <xsl:template match="orgName/orgTitle">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- start creating the new choice element -->
  <xsl:template match="corr[@sic]">
    <choice xmlns="http://www.tei-c.org/ns/1.0">
      <corr xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:value-of select="text()" />
      </corr>
      <sic xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:value-of select="@sic" />
      </sic>
    </choice>
  </xsl:template>

  <xsl:template match="sic[@corr]">
    <choice xmlns="http://www.tei-c.org/ns/1.0">
      <sic xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:value-of select="text()" />
      </sic>
      <corr xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:value-of select="@corr" />
      </corr>
    </choice>
  </xsl:template>

  <xsl:template match="abbr[@expan]">
    <choice xmlns="http://www.tei-c.org/ns/1.0">
      <abbr xmlns="http://www.tei-c.org/ns/1.0">
	<xsl:value-of select="text()" />
      </abbr>
      <expan xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:value-of select="@expan" />
      </expan>
    </choice>
  </xsl:template>

  <xsl:template match="expan[@abbr]">
    <choice xmlns="http://www.tei-c.org/ns/1.0">
      <expan xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:value-of select="text()" />
      </expan>
      <abbr xmlns="http://www.tei-c.org/ns/1.0">
	<xsl:value-of select="@abbr" />
      </abbr>
    </choice>
  </xsl:template>

  <!-- special consideration for <change> element -->
  <xsl:template match="change">
    <change xmlns="http://www.tei-c.org/ns/1.0">

      <xsl:apply-templates select="date" />

      <xsl:if test="respStmt/resp">
        <label>
	  <xsl:value-of select="respStmt/resp/text()"/>
	</label>
      </xsl:if>
      <xsl:for-each select="respStmt/name">
        <name xmlns="http://www.tei-c.org/ns/1.0">
          <xsl:apply-templates select="@*|*|comment()|processing-instruction()|text()" />
        </name>
      </xsl:for-each>
      <xsl:for-each select="item">
        <xsl:apply-templates select="@*|*|comment()|processing-instruction()|text()" />
      </xsl:for-each>
    </change>
  </xsl:template>


  <xsl:template match="respStmt[resp]">
    <respStmt xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:choose>
        <xsl:when test="resp/name">
          <resp xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:value-of select="resp/text()" />
          </resp>
          <xsl:for-each select="resp/name">
            <name xmlns="http://www.tei-c.org/ns/1.0">
              <xsl:apply-templates/>
            </name>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
          <name xmlns="http://www.tei-c.org/ns/1.0">
          </name>
        </xsl:otherwise>
      </xsl:choose>
    </respStmt>
  </xsl:template>

  <xsl:template match="q/@direct" />

  <xsl:template match="q">
    <q xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:apply-templates
	  select="@*|*|comment()|processing-instruction()|text()"/>
    </q>
  </xsl:template>


  <!-- if we are reading the P4 with a DTD,
       we need to avoid copying the default values
       of attributes -->

  <xsl:template match="@targOrder">
    <xsl:if test="not(translate(.,$uc,$lc) ='u')">
      <xsl:attribute name="targOrder">
        <xsl:value-of select="." />
      </xsl:attribute>
    </xsl:if>
  </xsl:template>


  <xsl:template match="@opt">
    <xsl:if test="not(translate(.,$uc,$lc) ='n')">
      <xsl:attribute name="opt">
        <xsl:value-of select="." />
      </xsl:attribute>
    </xsl:if>
  </xsl:template>


  <xsl:template match="@to">
    <xsl:if test="not(translate(.,$uc,$lc) ='ditto')">
      <xsl:attribute name="to">
        <xsl:value-of select="." />
      </xsl:attribute>
    </xsl:if>
  </xsl:template>


  <xsl:template match="@default">
    <xsl:choose>
      <xsl:when test="translate(.,$uc,$lc)= 'no'" />
      <xsl:otherwise>
        <xsl:attribute name="default">
          <xsl:value-of select="." />
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="@part">
    <xsl:if test="not(translate(.,$uc,$lc) ='n')">
      <xsl:attribute name="part">
        <xsl:value-of select="." />
      </xsl:attribute>
    </xsl:if>
  </xsl:template>


  <xsl:template match="@full">
    <xsl:if test="not(translate(.,$uc,$lc) ='yes')">
      <xsl:attribute name="full">
        <xsl:value-of select="." />
      </xsl:attribute>
    </xsl:if>
  </xsl:template>


  <xsl:template match="@from">
    <xsl:if test="not(translate(.,$uc,$lc) ='root')">
      <xsl:attribute name="from">
        <xsl:value-of select="." />
      </xsl:attribute>
    </xsl:if>
  </xsl:template>


  <xsl:template match="@status">
    <xsl:choose>
      <xsl:when test="parent::teiHeader">
        <xsl:if test="not(translate(.,$uc,$lc) ='new')">
          <xsl:attribute name="status">
            <xsl:value-of select="." />
          </xsl:attribute>
        </xsl:if>
      </xsl:when>
      <xsl:when test="parent::del">
        <xsl:if test="not(translate(.,$uc,$lc) ='unremarkable')">
          <xsl:attribute name="status">
            <xsl:value-of select="." />
          </xsl:attribute>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="status">
          <xsl:value-of select="." />
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="@place">
    <xsl:if test="not(translate(.,$uc,$lc) ='unspecified')">
      <xsl:attribute name="place">
        <xsl:value-of select="." />
      </xsl:attribute>
    </xsl:if>
  </xsl:template>


  <xsl:template match="@sample">
    <xsl:if test="not(translate(.,$uc,$lc) ='complete')">
      <xsl:attribute name="sample">
        <xsl:value-of select="." />
      </xsl:attribute>
    </xsl:if>
  </xsl:template>


  <xsl:template match="@org">
    <xsl:if test="not(translate(.,$uc,$lc) ='uniform')">
      <xsl:attribute name="org">
        <xsl:value-of select="." />
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template match="teiHeader/@type">
    <xsl:if test="not(translate(.,$uc,$lc) ='text')">
      <xsl:attribute name="type">
        <xsl:value-of select="." />
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <!-- yes|no to boolean -->

  <xsl:template match="@anchored">
    <xsl:attribute name="anchored">
      <xsl:choose>
        <xsl:when test="translate(.,$uc,$lc)='yes'">true</xsl:when>
        <xsl:when test="translate(.,$uc,$lc)='no'">false</xsl:when>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="sourceDesc/@default" />

  <xsl:template match="@tei">
    <xsl:attribute name="tei">
      <xsl:choose>
        <xsl:when test="translate(.,$uc,$lc)='yes'">true</xsl:when>
        <xsl:when test="translate(.,$uc,$lc)='no'">false</xsl:when>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@langKey" />

  <xsl:template match="@TEIform" />

  <!-- assorted atts -->
  <xsl:template match="@old" />

  <xsl:template match="@mergedin">
    <xsl:attribute name="mergedIn">
      <xsl:value-of select="." />
    </xsl:attribute>
  </xsl:template>

  <!-- handle names -->

  <xsl:template match="composer">
    <persName xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:attribute name="role">
        <xsl:value-of select="'composer'" />
      </xsl:attribute>
      <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()" />
    </persName>
  </xsl:template>

  <xsl:template match="div">
    <div xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:if test="descendant::hofClass">
        <xsl:attribute name="key">
          <xsl:value-of select="descendant::hofClass/@key" />
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()" />
    </div>
  </xsl:template>

  <xsl:template match="hofClass">
    <hi xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:attribute name="rendition">
        <xsl:value-of select="'#b #c'" />
      </xsl:attribute>
      <xsl:apply-templates select="*|@*[not('key')]|processing-instruction()|comment()|text()" />
    </hi>
  </xsl:template>

  <xsl:template match="publisher">
    <publisher xmlns="http://www.tei-c.org/ns/1.0">
      <orgName>
        <xsl:apply-templates select="@*" />
        <xsl:value-of select="." />
      </orgName>
    </publisher>
  </xsl:template>

</xsl:stylesheet>
