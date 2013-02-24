/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
/*
 *  Calculate destination point given start point lat/long (numeric degrees),
 *  bearing (numeric degrees) & distance (in m).
 *
 * from: Vincenty direct formula - T Vincenty, "Direct and Invers e Solutions of Geodesics on the
 *       Ellipsoid with application of nested equations", Survey Review, vol XXII no 176, 1975
 *       http://www.ngs.noaa.gov/PUBS_LIB/inverse.pdf
 */

function destVincenty(lat1, lon1, brng, dist) {
  var a = 6378137, b = 6356752.3142,  f = 1/298.257223563;  // WGS-84 ellipsiod
  var s = dist;
  var alpha1 = brng.toRad();
  var sinAlpha1 = Math.sin(alpha1);
  var cosAlpha1 = Math.cos(alpha1);

  var tanU1 = (1-f) * Math.tan(lat1.toRad());
  var cosU1 = 1 / Math.sqrt((1 + tanU1*tanU1)), sinU1 = tanU1*cosU1;
  var sigma1 = Math.atan2(tanU1, cosAlpha1);
  var sinAlpha = cosU1 * sinAlpha1;
  var cosSqAlpha = 1 - sinAlpha*sinAlpha;
  var uSq = cosSqAlpha * (a*a - b*b) / (b*b);
  var A = 1 + uSq/16384*(4096+uSq*(-768+uSq*(320-175*uSq)));
  var B = uSq/1024 * (256+uSq*(-128+uSq*(74-47*uSq)));

  var sigma = s / (b*A), sigmaP = 2*Math.PI;
  while (Math.abs(sigma-sigmaP) > 1e-12) {
    var cos2SigmaM = Math.cos(2*sigma1 + sigma);
    var sinSigma = Math.sin(sigma);
    var cosSigma = Math.cos(sigma);
    var deltaSigma = B*sinSigma*(cos2SigmaM+B/4*(cosSigma*(-1+2*cos2SigmaM*cos2SigmaM)-
      B/6*cos2SigmaM*(-3+4*sinSigma*sinSigma)*(-3+4*cos2SigmaM*cos2SigmaM)));
    sigmaP = sigma;
    sigma = s / (b*A) + deltaSigma;
  }

  var tmp = sinU1*sinSigma - cosU1*cosSigma*cosAlpha1;
  var lat2 = Math.atan2(sinU1*cosSigma + cosU1*sinSigma*cosAlpha1,
      (1-f)*Math.sqrt(sinAlpha*sinAlpha + tmp*tmp));
  var lambda = Math.atan2(sinSigma*sinAlpha1, cosU1*cosSigma - sinU1*sinSigma*cosAlpha1);
  var C = f/16*cosSqAlpha*(4+f*(4-3*cosSqAlpha));
  var L = lambda - (1-C) * f * sinAlpha *
      (sigma + C*sinSigma*(cos2SigmaM+C*cosSigma*(-1+2*cos2SigmaM*cos2SigmaM)));

  var revAz = Math.atan2(sinAlpha, -tmp);  // final bearing

  return new LatLon(lat2.toDeg(), lon1+L.toDeg());
}


// ---- the following are duplicated from LatLong.html ---- //


/*
 * construct a LatLon object: arguments in numeric degrees
 *
 * note all LatLong methods expect & return numeric degrees (for lat/long & for bearings)
 */
function LatLon(lat, lon) {
  this.lat = lat;
  this.lon = lon;
}


/*
 * represent point {lat, lon} in standard representation
 */
LatLon.prototype.toString = function() {
  return this.lat.toLat() + ', ' + this.lon.toLon();
}


// extend String object with method for parsing degrees or lat/long values to numeric degrees
//
// this is very flexible on formats, allowing signed decimal degrees, or deg-min-sec suffixed by
// compass direction (NSEW). A variety of separators are accepted (eg 3º 37' 09"W) or fixed-width
// format without separators (eg 0033709W). Seconds and minutes may be omitted. (Minimal validation
// is done).

String.prototype.parseDeg = function() {
  if (!isNaN(this)) return Number(this);                 // signed decimal degrees without NSEW

  var degLL = this.replace(/^-/,'').replace(/[NSEW]/i,'');  // strip off any sign or compass dir'n
  var dms = degLL.split(/[^0-9.]+/);                     // split out separate d/m/s
  for (var i in dms) if (dms[i]=='') dms.splice(i,1);    // remove empty elements (see note below)
  switch (dms.length) {                                  // convert to decimal degrees...
    case 3:                                              // interpret 3-part result as d/m/s
      var deg = dms[0]/1 + dms[1]/60 + dms[2]/3600; break;
    case 2:                                              // interpret 2-part result as d/m
      var deg = dms[0]/1 + dms[1]/60; break;
    case 1:                                              // decimal or non-separated dddmmss
      if (/[NS]/i.test(this)) degLL = '0' + degLL;       // - normalise N/S to 3-digit degrees
      var deg = dms[0].slice(0,3)/1 + dms[0].slice(3,5)/60 + dms[0].slice(5)/3600; break;
    default: return NaN;
  }
  if (/^-/.test(this) || /[WS]/i.test(this)) deg = -deg; // take '-', west and south as -ve
  return deg;
}
// note: whitespace at start/end will split() into empty elements (except in IE)


// extend Number object with methods for converting degrees/radians

Number.prototype.toRad = function() {  // convert degrees to radians
  return this * Math.PI / 180;
}

Number.prototype.toDeg = function() {  // convert radians to degrees (signed)
  return this * 180 / Math.PI;
}

// extend Number object with methods for presenting bearings & lat/longs

Number.prototype.toDMS = function() {  // convert numeric degrees to deg/min/sec
  var d = Math.abs(this);  // (unsigned result ready for appending compass dir'n)
  var deg = Math.floor(d);
  var min = Math.floor((d-deg)*60);
  var sec = ((d-deg-min/60)*3600).toFixed(4);  // mm precision
  // add leading zeros if required
  if (deg<100) deg = '0' + deg; if (deg<10) deg = '0' + deg;
  if (min<10) min = '0' + min;
  if (sec<10) sec = '0' + sec;
  return deg + '\u00B0' + min + '\u2032' + sec + '\u2033';
}

Number.prototype.toLat = function() {  // convert numeric degrees to deg/min/sec latitude
  return this.toDMS().slice(1) + (this<0 ? 'S' : 'N');  // knock off initial '0' for lat!
}

Number.prototype.toLon = function() {  // convert numeric degrees to deg/min/sec longitude
  return this.toDMS() + (this>0 ? 'E' : 'W');
}

