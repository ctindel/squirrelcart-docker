

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=ISO-8859-1" />

	<meta http-equiv="Page-Enter" CONTENT="progid:DXImageTransform.Microsoft.GradientWipe()" />

<meta HTTP-EQUIV="imagetoolbar" CONTENT="no">
<title>12_log_cabin_yellow_blue</title>
<link href="../res/styles.css" rel=stylesheet>
<!-- Include styles.inc from root image directory if present -->


<SCRIPT LANGUAGE="javascript">


	nextURL = 'orig2_13_log_cabin_lone_star.php';



	previousURL = 'orig2_10_scrapaholic.php';


showing = false;
shoExif = 0;
timeout = 0;
play = 0;
code = 0;
codePos = 0;


	delay = 3000;


play_img = new Image();
play_img.src = "../res/dark_grey/play.gif";
pause_img = new Image();
pause_img.src = "../res/dark_grey/pause.gif";

function toggleInfo() {
	if (showing == false) {
		if (document.all || document.getElementById) document.getElementById('imageinfo').style.visibility="visible";	// IE & Gecko
		else document.layers['imageinfo'].visibility="show"; // Netscape 4
		showing = true;
		code = "X";
		appendURL();
	}
	else {
		if (document.all || document.getElementById) document.getElementById('imageinfo').style.visibility="hidden";	// IE & Gecko
		else document.layers['imageinfo'].visibility="hide";	// Netscape 4
		showing = false;
		hideExif();
	}
}

function hideExif() {
	code = "X";
	chkURL = nextURL;
	checkCode(code, chkURL);
	if (codePos == 1 || codePos == 3) {
	delCode();
	return nextURL;
	}
}

function checkCode(code, chkURL) {
	if (chkURL.charAt(chkURL.length - 1) == code) {
	codePos = 1;
	return codePos;
	}
	if (chkURL.charAt(chkURL.length - 3) == code) {
	codePos = 3;
	return codePos;
	}
}

function delCode() {
	if (codePos == 1) {
	nextURL = nextURL.substring(0, nextURL.length - 2);
	return nextURL;
	}
	if (codePos == 3) {
	endCode = nextURL.substring(nextURL.length - 2);
	nextURL = nextURL.substring(0, nextURL.length - 4);
	nextURL = nextURL + endCode;
	return nextURL;
	}
}

function checkURLend() {
	chkURL = window.location.href;
	checkCode(code, chkURL);
	if (codePos > 0) {
	appendURL();
	codePos = 0;
		if (code == "S") {
		play = 1;
		return play;
		}
		if (code == "X") {
		shoExif = 1;
		return shoExif;
		}
	}
}

function appendURL() {
	nextURL = nextURL + "?" + code;
	return nextURL;
}

function pauseURL() {
	code = "S";
	chkURL = nextURL;
	checkCode(code, chkURL);
	if (codePos == 1 || codePos == 3) {
	delCode();
	}
}

function slide() {
	code = "S";
	checkURLend();
	if (play == 1) {
		timeout = setTimeout(next,delay);
	} else {document.images['playpause'].src = play_img.src;
	}
	code = "X";
	chkURL = window.location.href;
	checkCode(code, chkURL);
	if (codePos > 0) {
		showing = false;
		toggleInfo();
	}
}

function next() {
	document.location.href=nextURL;
}

function previous() {
	document.location.href=previousURL;
}

function playpause() {
	if (timeout) {
		clearTimeout(timeout);
		timeout = 0;
		if (play == 0);
		document.images['playpause'].src = play_img.src;
		pauseURL();
	} else {
		document.images['playpause'].src = pause_img.src;
		play = 1;
		code = "S";
		appendURL();
		next();
	}
}
</SCRIPT>


</head>

<body id="slide" onload="slide()" marginwidth="0" marginheight="0">
<DIV style="position: absolute; top: 5px; right: 140; width: 100%; text-align: right; font-size: 14px; font-weight: bold; color: #333333;">
12_log_cabin_yellow_blue
</DIV>
<DIV style="position: absolute; top: 3px; right: 142; width: 100%; text-align: right; font-size: 14px; font-weight: bold; color: #CCCCCC;">
12_log_cabin_yellow_blue
</DIV>

<div style="position:absolute; top:0; right:0"><table cellspacing=0 cellpadding=0 border=0><tr>
<!-- Up button -->
<td> <a href="orig_12_log_cabin_yellow_blue.php"><img src="../res/dark_grey/up.gif" border=0 ALT=" Up one level "></a> </td>
<!-- Previous button -->
<td> <a href="orig2_10_scrapaholic.php"><img src="../res/dark_grey/previous.gif" alt="Previous page" border=0></a></a> </td>
<!-- Play/paues button -->
<td> <a href="javascript:playpause()"><img src="../res/dark_grey/pause.gif" name="playpause" ALT="Start slideshow" border=0></a> </td>
<!-- Next button -->
<td> <a href="orig2_13_log_cabin_lone_star.php"><img src="../res/dark_grey/next.gif" alt="Next page" border=0></a> </td>
</tr></table></div>

<!-- Next Image -->
<table width="100%" height="100%" cellspacing=0 cellpadding=0><tr><td align="center" valing="top">
<A HREF="orig2_13_log_cabin_lone_star.php"><IMG SRC="../12_log_cabin_yellow_blue.jpg" WIDTH="1536" HEIGHT="1024" BORDER=0 ALT="  12_log_cabin_yellow_blue  
  
   Next page   "></A></td></tr></table>

<BR>
<!-- Image info button if camera information exists -->

</CENTER>
</DIV>
<BR>
<CENTER>
<TABLE WIDTH="80%" cellpadding="0" cellspacing="0">
<TR><TD>
<!-- Always display comment below image (if exists) -->

<!-- Try to extract the comment from a file carrying the same base name as this image --><BR>
<DIV CLASS="comment">
	

<!-- Extract the comment from a caption.txt file where the fileName is the key -->

</DIV>

</TD></TR>
<TR><TD align="center">

</TD></TR>
<TR><TD align="center">

</TD></TR>
<TR><TD>
<DIV CLASS="footer">

</DIV>
</TD></TR>
<TR><TD>
<DIV CLASS="footer">

<img src="../res/spacer.gif" border="0" width="40" height="1">
<br><br>

</DIV>
</TD></TR>
</TABLE>
</CENTER>
<CENTER>

<A HREF="orig_10_scrapaholic.php"> Previous page </A>
<A HREF="orig2_10_scrapaholic.php"> &nbsp;&nbsp;&nbsp;&nbsp; Previous Image </A>

<A HREF="orig_12_log_cabin_yellow_blue.php" onclick="javascript:self.close()">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Close &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</A>

<A HREF="orig2_13_log_cabin_lone_star.php">Next Image &nbsp;&nbsp;&nbsp;&nbsp; </A>
<A HREF="orig_13_log_cabin_lone_star.php"> Next page </A>
<BR><BR>

<!-- preload next image -->
                   
        <script language="JavaScript" type="text/javascript">
                next_image = new Image();
                next_image.src = "../13_log_cabin_lone_star.jpg";
        </script>

</CENTER>
</body>
</html>
