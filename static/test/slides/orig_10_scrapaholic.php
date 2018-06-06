
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

	<meta http-equiv="Page-Enter" CONTENT="progid:DXImageTransform.Microsoft.GradientWipe()" />

<meta HTTP-EQUIV="imagetoolbar" CONTENT="no">
<meta http-equiv="content-type" content="text/html; charset=ISO-8859-1" />
<title>10_scrapaholic</title>
<link href="../res/styles.css" rel=stylesheet>
<!-- Include styles.inc from root image directory if present -->


<script type="text/javascript">


	nextURL = 'orig_12_log_cabin_yellow_blue.php';


timeout = 0;
play_img = new Image();
play_img.src = "../res/dark_grey/play.gif";
pause_img = new Image();
pause_img.src = "../res/dark_grey/pause.gif";

delay = 5000;

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
10_scrapaholic
</DIV>
<DIV style="position: absolute; top: 3px; right: 142; width: 100%; text-align: right; font-size: 14px; font-weight: bold; color: #CCCCCC;">
10_scrapaholic
</DIV>
<div style="position:absolute; top:0; right:0"><table cellspacing=0 cellpadding=0 border=0><tr>
<!-- Up button -->
<td> <a href="10_scrapaholic.php"><img src="../res/dark_grey/up.gif" border=0 ALT=" Close   
Up one level "></a> </td>
<!-- Previous button -->
<td> <a href="orig_09_bargello_wave.php"><img src="../res/dark_grey/previous.gif" alt="Previous page" border=0></a></a> </td>
<!-- Play/paues button -->
<td> <a href="javascript:playpause()"><img src="../res/dark_grey/pause.gif" name="playpause" ALT="Slide Show" border=0></a> </td>
<!-- Next button -->
<td> <a href="orig_12_log_cabin_yellow_blue.php"><img src="../res/dark_grey/next.gif" alt="Next page" border=0></a> </td>
</tr></table></div>

<!-- Image with link to original -->
<table width="100%" height="100%" cellspacing=0 cellpadding=0><tr><td align="center"><a href="orig2_10_scrapaholic.php"><script type="text/javascript">
setVal();
sizeImg(800, 533);
document.write('<img src="../10_scrapaholic.jpg" width="' + tWidth + '" height="' + tHeight + '" border=0 alt="   10_scrapaholic  + ">');
</script></a></td></tr></table>

<!-- Always display comment (if exists) -->

<!-- Try to extract the comment from a file carrying the same base name as this image --><BR>
<DIV style="position: absolute; top: 5px; left: 7; width: 90%; text-align: left; font-size: 16px; font-weight: bold; color: #CCCCCC;">

	

<!-- Extract the comment from a caption.txt file where the fileName is the key -->

</DIV>

<DIV style="position: absolute; top: 6px; left: 8; width: 90%;  text-align: left; font-size: 16px; font-weight: bold; color: #333333;">
	

<!-- Extract the comment from a caption.txt file where the label is the key -->

</DIV>


<!-- preload next image -->
                   
        <script language="JavaScript" type="text/javascript">
                next_image = new Image();
                next_image.src = "../12_log_cabin_yellow_blue.jpg";
        </script>

</body>
</html>
