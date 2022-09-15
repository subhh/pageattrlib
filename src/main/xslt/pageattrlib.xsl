<xsl:transform version="3.0"
               xmlns="http://www.tei-c.org/ns/1.0"
               xmlns:fn="https://github.com/subhh/pageattrlib"
               xmlns:map="http://www.w3.org/2005/xpath-functions/map"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template name="fn:properties-to-fs" as="element(Q{http://www.tei-c.org/ns/1.0}fs)?">
    <xsl:param name="properties" as="map(*)" required="true"/>
    <fs>
      <xsl:for-each select="map:keys($properties)">
        <xsl:variable name="value" select="map:get($properties, .)"/>
        <f name="{.}">
          <xsl:choose>
            <xsl:when test="$value instance of map(*)+">
              <xsl:for-each select="$value">
                <xsl:call-template name="fn:properties-to-fs">
                  <xsl:with-param name="properties" as="map(*)" select="."/>
                </xsl:call-template>
              </xsl:for-each>
            </xsl:when>
            <xsl:when test="$value instance of xs:float or $value instance of xs:double or $value instance of xs:decimal">
              <numeric value="{$value}"/>
            </xsl:when>
            <xsl:when test="$value instance of xs:boolean">
              <binary value="{$value}"/>
            </xsl:when>
            <xsl:otherwise>
              <string><xsl:value-of select="$value"/></string>
            </xsl:otherwise>
          </xsl:choose>
        </f>
      </xsl:for-each>
    </fs>
  </xsl:template>

  <xsl:function name="fn:properties-to-map" as="map(xs:string, map(xs:string, item()))">
    <xsl:param name="properties" as="xs:string"/>
    <xsl:variable name="parsed-properties" as="map(xs:string, map(xs:string, item()))*">
      <xsl:analyze-string select="$properties" regex="([a-zA-Z]+) \{{([^\}}]*)\}}">
        <xsl:matching-substring>
          <xsl:variable name="selector" as="xs:string" select="regex-group(1)"/>
          <xsl:variable name="props" as="xs:string*" select="tokenize(regex-group(2), ';') ! normalize-space()"/>
          <xsl:map-entry key="$selector">
            <xsl:map>
              <xsl:for-each select="$props[normalize-space()]">
                <xsl:choose>
                  <xsl:when test="contains(., ':')">
                    <xsl:map-entry key="substring-before(., ':')" >
                      <xsl:variable name="value" as="xs:string" select="normalize-space(substring-after(., ':'))"/>
                      <xsl:choose>
                        <xsl:when test="lower-case($value) = ('true', 'false')">
                          <xsl:sequence select="xs:boolean(lower-case($value))"/>
                        </xsl:when>
                        <xsl:when test="$value castable as xs:integer">
                          <xsl:sequence select="xs:integer($value)"/>
                        </xsl:when>
                        <xsl:when test="$value castable as xs:decimal">
                          <xsl:sequence select="xs:decimal($value)"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:sequence select="xs:string($value)"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:map-entry>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:message terminate="yes" expand-text="yes">Invalid property: {.}</xsl:message>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </xsl:map>
          </xsl:map-entry>
        </xsl:matching-substring>
      </xsl:analyze-string>
    </xsl:variable>
    <xsl:sequence select="map:merge($parsed-properties, map{'duplicates': 'combine'})"/>
  </xsl:function>

</xsl:transform>
