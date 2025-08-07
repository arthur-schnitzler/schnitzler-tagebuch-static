<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xsl xs" version="2.0">
    <xsl:include href="./params.xsl"/>
    <xsl:template match="/" name="html_head">
        <xsl:param name="html_title" select="$project_short_title"/>
        <xsl:param name="entry_date" select="entry_date"/>
        <xsl:param name="page_url" select="''"/>
        <xsl:param name="meta_description" select="''"/>
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
            <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
            <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"/>
            <meta name="mobile-web-app-capable" content="yes"/>
            <meta name="apple-mobile-web-app-capable" content="yes"/>
            <meta name="apple-mobile-web-app-title" content="{$html_title}"/>
            <meta name="docTitle" class="staticSearch_docTitle" content="{$html_title}"/>
            <xsl:if test="$meta_description != ''">
                <meta name="description" content="{$meta_description}"/>
            </xsl:if>
            <meta name="msapplication-TileColor" content="#ffffff"/>
            <meta name="msapplication-TileImage" content="{$project_logo}"/>
            <link rel="icon" type="image/svg+xml" href="{$project_logo}" sizes="any"/>
            <link rel="shortcut icon" type="image/x-icon" href="./img/favicon/favicon.ico"/>
            <link rel="icon" type="image/x-icon" href="./img/favicon/favicon.ico"/>
            <link rel="apple-touch-icon" sizes="57x57" href="./img/favicon/apple-icon-57x57.png"/>
            <link rel="apple-touch-icon" sizes="60x60" href="./img/favicon/apple-icon-60x60.png"/>
            <link rel="apple-touch-icon" sizes="72x72" href="./img/favicon/apple-icon-72x72.png"/>
            <link rel="apple-touch-icon" sizes="76x76" href="./img/favicon/apple-icon-76x76.png"/>
            <link rel="apple-touch-icon" sizes="114x114" href="./img/favicon/apple-icon-114x114.png"/>
            <link rel="apple-touch-icon" sizes="120x120" href="./img/favicon/apple-icon-120x120.png"/>
            <link rel="apple-touch-icon" sizes="144x144" href="./img/favicon/apple-icon-144x144.png"/>
            <link rel="apple-touch-icon" sizes="152x152" href="./img/favicon/apple-icon-152x152.png"/>
            <link rel="apple-touch-icon" sizes="180x180" href="./img/favicon/apple-icon-180x180.png"/>
            <link rel="icon" type="image/png" sizes="192x192"
                href="./img/favicon/android-icon-192x192.png"/>
            <link rel="icon" type="image/png" sizes="32x32" href="./img/favicon/favicon-32x32.png"/>
            <link rel="icon" type="image/png" sizes="96x96" href="./img/favicon/favicon-96x96.png"/>
            <link rel="icon" type="image/png" sizes="16x16" href="./img/favicon/favicon-16x16.png"/>
            <meta name="docSortKey" class="staticSearch_docSortKey" content="d_{$entry_date}"/>
            <link rel="profile" href="http://gmpg.org/xfn/11"/>
            
            <!-- Citation metadata for Wikipedia automatic importer -->
            <meta name="citation_title" content="{$html_title}"/>
            <meta name="citation_author" content="Arthur Schnitzler"/>
            <meta name="citation_publication_title" content="Tagebuch (1879–1931)"/>
            <meta name="citation_publisher" content="Austrian Centre for Digital Humanities"/>
            <meta name="citation_language" content="de"/>
            <meta name="citation_online_date" content="{format-date(current-date(), '[Y0001]-[M01]-[D01]')}"/>
            <xsl:if test="$entry_date != ''">
                <meta name="citation_publication_date" content="{$entry_date}"/>
            </xsl:if>
            <xsl:if test="$page_url != ''">
                <meta name="citation_public_url" content="{$page_url}"/>
            </xsl:if>
            
            <!-- German Wikipedia Internetquelle template parameters -->
            <meta name="DC.title" content="{$html_title}"/>
            <meta name="DC.creator" content="Arthur Schnitzler"/>
            <meta name="DC.publisher" content="Austrian Centre for Digital Humanities"/>
            <meta name="DC.date" content="{format-date(current-date(), '[Y0001]-[M01]-[D01]')}"/>
            <meta name="DC.language" content="de"/>
            <meta name="DC.format" content="text/html"/>
            <xsl:if test="$page_url != ''">
                <meta name="DC.identifier" content="{$page_url}"/>
            </xsl:if>
            <xsl:if test="$entry_date != ''">
                <meta name="DC.coverage" content="{$entry_date}"/>
            </xsl:if>
            
            <!-- Wikipedia Internetquelle specific metadata -->
            <meta name="author" content="Arthur Schnitzler"/>
            <meta name="work" content="Tagebuch (1879–1931). Digitale Edition"/>
            <meta name="publisher" content="Austrian Centre for Digital Humanities"/>
            <meta name="language" content="de"/>
            <xsl:if test="$entry_date != ''">
                <meta name="date" content="{$entry_date}"/>
            </xsl:if>
            
            <!-- Schema.org metadata for better Wikipedia recognition -->
            <meta property="og:title" content="{$html_title}"/>
            <meta property="og:type" content="article"/>
            <meta property="og:site_name" content="Tagebuch (1879–1931). Digitale Edition"/>
            <xsl:if test="$page_url != ''">
                <meta property="og:url" content="{$page_url}"/>
            </xsl:if>
            <meta name="article:author" content="Arthur Schnitzler"/>
            <xsl:if test="$entry_date != ''">
                <meta name="article:published_time" content="{$entry_date}"/>
            </xsl:if>
            
            <title>
                <xsl:value-of select="$html_title"/>
            </title>
            <script src="https://code.jquery.com/jquery-3.6.3.min.js" integrity="sha256-pvPw+upLPUjgMXY0G+8O0xUf+/Im1MZjXxxgOcBQBXU=" crossorigin="anonymous"/>
            <link
                href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css"
                rel="stylesheet"
                integrity="sha384-KK94CHFLLe+nY2dmCWGMq91rCGa5gtU4mk92HdvYe+M/SXH301p5ILy+dN9+nJOZ"
                crossorigin="anonymous"/>
            <link rel="stylesheet"
                href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"
                integrity="sha512-iecdLmaskl7CVkqkXNQ/ZH/XLlvWZOJyj7Yy7tcenmpD1ypASozpmT/E0iPtmFIB46ZmdtAc9eNBvH0H/ZpiBw=="
                crossorigin="anonymous" referrerpolicy="no-referrer"/>
            <link rel="stylesheet" href="css/style.css" type="text/css"/>
            <script src="https://code.jquery.com/jquery-3.6.0.min.js" integrity="sha256-/xUj+3OJU5yExlq6GSYGSHk7tPXikynS7ogEvDej/m4=" crossorigin="anonymous"/>
            <!-- Begin Cookie Consent plugin by Silktide - http://silktide.com/cookieconsent -->
            <script type="text/javascript">
                window.cookieconsent_options = {
                    "message": "This website uses cookies to ensure you get the best experience on our website",
                    "dismiss": "Got it!",
                    "learnMore": "More info",
                    "link": "imprint.html",
                    "theme": "dark-bottom"
                };</script>
            <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/cookieconsent2/1.0.9/cookieconsent.min.js"/>
            <!-- End Cookie Consent plugin -->
            <!-- Matomo -->
            <script type="text/javascript">
                var _paq = _paq ||[];
                /* tracker methods like "setCustomDimension" should be called before "trackPageView" */
                _paq.push([ 'trackPageView']);
                _paq.push([ 'enableLinkTracking']);
                (function () {
                    var u = "https://matomo.acdh.oeaw.ac.at/";
                    _paq.push([ 'setTrackerUrl', u + 'piwik.php']);
                    _paq.push([ 'setSiteId', '101']);
                    var d = document, g = d.createElement('script'), s = d.getElementsByTagName('script')[0];
                    g.type = 'text/javascript'; g. async = true; g.defer = true; g.src = u + 'piwik.js'; s.parentNode.insertBefore(g, s);
                })();</script>
            <!-- End Matomo Code -->
        </head>
    </xsl:template>
</xsl:stylesheet>
