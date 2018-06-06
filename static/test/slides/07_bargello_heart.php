
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=ISO-8859-1" />
<STYLE><!--
 body {
	margin: 0;
	overflow: visible;
}
--></STYLE>
<meta http-equiv="content-type" content="text/html; charset=ISO-8859-1" />

	<meta http-equiv="Page-Enter" CONTENT="progid:DXImageTransform.Microsoft.GradientWipe()" />

<meta HTTP-EQUIV="imagetoolbar" CONTENT="no">
<title>07_bargello_heart</title>
<link href="../res/styles.css" rel=stylesheet>
<!-- Include styles.inc from root image directory if present -->


<script type="text/javascript">


	nextURL = '08_spinning_star_king.php';


timeout = 0;
play_img = new Image();
play_img.src = "../res/dark_grey/play.gif";
pause_img = new Image();
pause_img.src = "../res/dark_grey/pause.gif";

delay = 5000;
if (window.opener && window.opener.document.forms.settings) {
	form = window.opener.document.forms.settings;
	delay = form.delay.value*1000;
	fullscreen = form.fullscreen.checked;
}

function slide() {
	timeout = setTimeout(next,delay);
}

function next() {
	document.location.href=nextURL;
}

function playpause() {
	if (timeout) {
		clearTimeout(timeout);
		timeout = 0;
		document.images['playpause'].src = play_img.src;
	} else {
		document.images['playpause'].src = pause_img.src;
		next();
	}
}

function setVal()
{
   colCount = 5;
   rowCount = 4;
   win = new Array ("w","h");
   avail = new Array ("w","h");
   obso = new Array ("w","h");
   imgSp = new Array ("w","h");
   headSp = 115;                      // Space for the title and the controls, dependant on stylesheet
   lablSp = 12;                       // Rowheight for the labels, dependant on stylesheet
   footSp = 35;                       // Space for the jAlbum link and bottom margin
   ixMarg = 30;                       // left and right margin value
   scrollSp = 16;                     // width or height of scrollbars - shouldn't really be needed   
   addSpH = 40;                       // Additional vertical space needed, probably due too browser dependent rendering
   addSpH = 0;                        // Additional vertical space needed, probably due too browser dependent rendering
   addSpW = 0;                        // Additional horizontal space needed, probably due too browser dependent rendering

   if (window.innerWidth)
   {
      win["w"] = window.innerWidth;
      win["h"] = window.innerHeight;
   }

   else if (document.body.clientWidth)
   {
      win["w"] = document.body.clientWidth;
      win["h"] = document.body.clientHeight;
   }

   else
   {
      win["w"] = screen.width - 25;
      win["h"] = screen.height - 115;
   }


   obso["w"] = (ixMarg * 2) + scrollSp + addSpW;
   obso["h"] = headSp + lablSp + footSp + scrollSp + addSpH;

   avail["w"] = win["w"];// - obso["w"];
   avail["h"] = win["h"];// - obso["h"];
//alert(avail["w"] + "," + avail["h"]);
	 }

function sizeImg(imgW, imgH)
{
   imgRatio = imgW / imgH;

   function scaleWB() { tWidth = avail["w"]; tHeight = tWidth / imgRatio; }
   function scaleBW() { tHeight = avail["h"]; tWidth = tHeight * imgRatio; }

   if (imgRatio >= 1)        // determination of oriontation of image
   {
      scaleWB();
      if (tHeight > avail["h"]) { scaleBW(); }

   }
   else
   {
      scaleBW();
      if (tWidth > avail["w"]) { scaleWB(); }
   }
}

window.focus();
</script>

</head>

<body id="slide" onload="slide()" marginwidth="0" marginheight="0">
<DIV style="position: absolute; top: 5px; right: 140; width: 100%; text-align: right; font-size: 14px; font-weight: bold; color: #333333;">
07_bargello_heart
</DIV>
<DIV style="position: absolute; top: 3px; right: 142; width: 100%; text-align: right; font-size: 14px; font-weight: bold; color: #CCCCCC;">
07_bargello_heart
</DIV>
<div style="position:absolute; top:0; right:0">
<table cellspacing=0 cellpadding=0 border=0><tr>
<!-- Close button -->
<td><a href="javascript:window.close()"><img src="../res/dark_grey/up.gif" border=0 ALT="Close"></a></td>
<!-- Previous button -->
<td>
<a href="06_autumn_splendor_king.php"><IMG SRC="../res/dark_grey/previous.gif" ALT="Previous page" BORDER=0 vspace=0></A>
</td>
<!-- Play/pause button -->
<td><a href="javascript:playpause()"><img src="../res/dark_grey/pause.gif" name="playpause" ALT="Slide Show" border=0></a></td>
<!-- Next button -->
<td>
<A HREF="08_spinning_star_king.php"><IMG SRC="../res/dark_grey/next.gif" ALT="Next page" BORDER=0 vspace=0></A></td>
</tr></table></div>

<!-- Image, maybe with link to original -->

<!-- Create a slide page for the original image too and link to that one instead of linking to an image -->


<!-- Image with link to original scaled-->
<table width="100%" height="100%" cellspacing=0 cellpadding=0><tr><td align="center"><a href="orig_07_bargello_heart.php">
<script type="text/javascript">
setVal();
sizeImg(800, 600);
document.write('<img src="07_bargello_heart.jpg" width="' + tWidth + '" height="' + tHeight + '" border=0 alt="  07_bargello_heart    See Original Image  ">');
</script></a></td></tr></table>


<!-- Always display comment (if exists) -->

<!-- Try to extract the comment from a file carrying the same base name as this image --><BR>
<DIV style="position: absolute; top: 5px; left: 7; width: 90%; text-align: left; font-size: 16px; font-weight: bold; color: #CCCCCC;">

	

<!-- Extract the comment from a caption.txt file where the label is the key -->

</DIV>

<DIV style="position: absolute; top: 6px; left: 8; width: 90%;  text-align: left; font-size: 16px; font-weight: bold; color: #333333;">
	

<!-- Extract the comment from a caption.txt file where the fileName is the key -->

</DIV>


<TABLE WIDTH="100%" cellpadding="0" cellspacing="0">
<TR>
<TD Width="12%"></TD>
<TD Width="20%"></TD>
<TD Width="50%"></TD></TR></TABLE>
<p></p>

<!-- preload next image -->
                   
        <script language="JavaScript" type="text/javascript">
                next_image = new Image();
                next_image.src = "08_spinning_star_king.jpg";
        </script>

</body>
</html>
