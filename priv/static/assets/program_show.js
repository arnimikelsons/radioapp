// function displayShow accepts the diff argument which is the time difference between now and the day of the show 
// to display on the screen. If it's the most recent airing, it also creates the audio player in the <audio> tag
// this function is called 8 times in order to show the last 8 episodes. each time it is called with a different diff value
// representing the difference between now and the date of the show to display
function displayShow( week, diff, show ) { 
  d = new Date();
  d.setDate( d.getDate() - diff );
  d.setHours( Math.floor( show.start / 100 ) );
  var divName = ( week ) ? "thisWeek" : "lastWeek";
  var year = d.getFullYear();
  var moy = d.getMonth() + 1;
  moy = ( moy < 10 ) ? "0" + moy : moy;
  var dom = d.getDate();
  dom = ( dom < 10 ) ? "0" + dom : dom;
  var hour = d.getHours();
  hour = ( hour < 10 ) ? "0" + hour : hour;
  // is the show more than an hour long? Then grab both files. what if a show is 3 hours long?
  var length = ( show.end - show.start );
  var minutes;
  var topOfHour = true;
  var downloadText;
  
  if ( length == 29 ) { minutes = 30; downloadText = "Download file";  }
  else if ( length < 100 ) { minutes = 60; downloadText = "Download file";  }
  else if ( length == 129 ) { minutes = 90; downloadText = "Hour 1"; }
  else if ( length < 200 ) { minutes = 120; downloadText = "Hour 1"; }
  else if ( length == 229 ) { minutes = 150; downloadText = "Hour 1"; }
  else if ( length < 300 ) { minutes = 180; downloadText = "Hour 1"; }
  
  if ( show.start % 100 == 30 ) { 
    topOfHour = false; 
    downloadText = "Half Hour";
  }
  
  // Create date text for nodes
  var dateText = weekDay[d.getDay()] + ", " + month[d.getMonth()] + " " + d.getDate() + ", " + d.getFullYear(); 
  
  if ( !latestEpisodePlayer ) {
    // Create node for playback in browser
    var latestEpisodeNode = document.createElement("p");
    var titleText = "Latest episode: " + dateText;
    var titleNode = document.createTextNode(titleText);
    latestEpisodeNode.appendChild(titleNode);
        $('#music2Container').append(latestEpisodeNode);
    
    var node = document.createElement("audio");
    node.setAttribute("controls","controls");
    node.id = "music2";
    
    if ( !topOfHour ) {
      // if the show airs at the half hour mark, start playback at 1800 seconds into the file i.e. 30 minutes
      console.log("Show starts at half hour");
      node.currentTime=1800;
    } else {
        console.log("This show starts on the hour");
    }
    
    var sourceNode = document.createElement("source");
    sourceNode.setAttribute("src", "https://audio.cfrc.ca/archives/"+ year + "-" + moy + "-" + dom + "-" + hour + ".mp3" );
    sourceNode.setAttribute("type", "audio/mpeg");
    node.appendChild(sourceNode);
    //Append everything inside the music player container
    var musicPlayer = document.getElementById("music2Container");  
    
    //var linebreak = document.createElement("br");
    //musicPlayer.appendChild(linebreak);
    musicPlayer.appendChild(node);
    
  }
  
  // Set the audioPlayer boolean to true; so next time it won't create the player module
  latestEpisodePlayer = true;
  
  // Write out the date
  var dateNode = document.createTextNode( dateText + ": ");   
  document.getElementById(divName).appendChild(dateNode);
  
  
  // Create a clickable download link
  var a = document.createElement("a");
  var linkText = document.createTextNode(downloadText);
  a.appendChild(linkText);
  a.href = "https://audio.cfrc.ca/archives/" + year + "-" + moy + "-" + dom + "-" + hour + ".mp3";
  document.getElementById(divName).appendChild(a);
  
  if ( minutes > 60 ) {
      var secondHr = parseInt( hour ) + 1;
    secondHr = ( secondHr < 10 ) ? "0" + secondHr : secondHr;
    var a = document.createElement("a");
    var linkText = document.createTextNode(" Hour 2 ");
    a.appendChild(linkText);
    a.href = "https://audio.cfrc.ca/archives/" + year + "-" + moy + "-" + dom + "-" + secondHr + ".mp3";
    var spaceText = document.createTextNode(" | ");
    document.getElementById(divName).appendChild(spaceText);
    document.getElementById(divName).appendChild(a);
  }
  if ( minutes > 120 ) {
      var thirdHr = parseInt( hour ) + 2;
    thirdHr = ( thirdHr < 10 ) ? "0" + thirdHr : thirdHr;
    var a = document.createElement("a");
    var linkText = document.createTextNode(" Hour 3 ");
    a.appendChild(linkText);
    a.href = "https://audio.cfrc.ca/archives/" + year + "-" + moy + "-" + dom + "-" + thirdHr + ".mp3";
    var space2Text = document.createTextNode(" | ");
    document.getElementById(divName).appendChild(space2Text);
    document.getElementById(divName).appendChild(a);
  }
  
    //Add a linebreak
  var linebreak = document.createElement("br");
  document.getElementById(divName).appendChild(linebreak);
  
}

// *****Initialize some variables before executing*****
var pageTitle;
var page = document.getElementById("pageShowTitle");
if (page !== null) {
  pageTitle = page.innerHTML;
}
var latestEpisodePlayer = false; // record whether the archive audio player has already been created
  
// *****Here's where the execution begins***** 
for (var i = 0; i < shows.length; i++) {
  if ( shows[i].name === pageTitle) { // If this page title is a show in the schedule.js file
  // Set the titles to be visible  
  document.getElementById("archivesTitle").style.display = "initial";
  document.getElementById("archivesSubTitle").style.display = "initial";
  
  //declare your variables first
  var d = new Date();
  var diff = 0; // Store the difference between today's date and the date the show aired last
  var nowDayOfWeek = d.getDay();
  var nowInteger = d.getDay() * 10000 + d.getHours() * 100 + d.getMinutes();
  var offsetAmount = d.getTimezoneOffset() / 60 * 100;
  var kTownTime = nowInteger + offsetAmount - 500;
  var thisWeek = false; // boolean value to know if we're displaying shows from this week or last
  var month = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
  var weekDay = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]; 
  if ( shows[i].biweekly != null ) { // The show happens every other week, calculate which show aired most recently
    
    var year = d.getFullYear();
        var start = new Date(year, 0, 1); // the first day of this year
    // Now get the first show day of the year (e.g. the show is on wednesdays, so get the first wednesday of the year
    var dow = start.getDay();
    
    var firstSOY; // first show of year, i.e. the day of the first show of the year
    if ( dow == shows[i].day ) { firstSOY = 1 }
    else if ( dow < shows[i].day ) { firstSOY = shows[i].day - dow + 1}
    else if ( dow > shows[i].day ) { firstSOY = shows[i].day + 7 - dow + 1 }
    // Get today's day of the year
    var now = new Date();
        var diff = (now - start) + ((start.getTimezoneOffset() - now.getTimezoneOffset()) * 60 * 1000);	
        var oneDay = 1000 * 60 * 60 * 24;
        var todayDOY = Math.ceil(diff / oneDay); // todays Day Of Year
    
    // How many shows aired this year i.e. on odd or even number of times?
    var totalSTY = todayDOY - firstSOY;
    totalSTY = Math.floor(totalSTY / 7 ) + 1;  // total number of Shows aired This Year
    
    // Odd or even is the way to find out which show aired more recently
    if ( totalSTY % 2 == shows[i].biweekly || totalSTY % 2 + 2 == shows[i].biweekly ) {  
      // i.e. if the modulus is 1, and this biweekly is 1, it means this show aired most recently 
      // also if the modulus is 0, and the biweekly is 2, it means the show aired most recently
            // Iterate through the last 1 episodes
      for ( k = 0; k < 7; k=k+2 ) { 
          if ( shows[i].day < nowDayOfWeek ) { // This show aired earlier this week          
          diff = nowDayOfWeek - shows[i].day + (7 * k);           
        } else if ( shows[i].day > nowDayOfWeek ) { // the show aired most recently last week          
          diff = nowDayOfWeek + 7 - shows[i].day + (7 * k);         
        } else { // Today is the day's show. Either it already aired or hasn't yet aired:        
          if ( kTownTime > shows[i].day * 10000 + shows[i].end + 40 ) { // It's already aired         
            diff = nowDayOfWeek - shows[i].day + (7 * k);         
          } else { // It was a week ago today it last aired        
            diff = nowDayOfWeek + 7 - shows[i].day + (7 * k);          
          }
        }
        displayShow( thisWeek, diff, shows[i] );   
        //console.log("k: " + k);
      }    
    } else { // This show did not air most recently
          for ( m = 1; m < 7; m=m+2 ) { 
                
            if ( shows[i].day < nowDayOfWeek ) { // This show aired earlier this week        
              diff = nowDayOfWeek - shows[i].day + (7 * m);          
            } else if ( shows[i].day > nowDayOfWeek ) { // the show aired most recently last week         
              diff = nowDayOfWeek + 7 - shows[i].day + (7 * m);        
            } else { // Today is the day's show. And it already aired a week ago, it does not air today              
              diff = nowDayOfWeek - shows[i].day + (7 * m);    
            }
            displayShow( thisWeek, diff, shows[i] ); 
            //console.log("m: " + m);
            
      }  
    }
  }
        
  for ( var j = 0; j < 8; j++ ) { 
    if ( shows[i].biweekly != null ) { // if the show is biweekly, don't execute during this for loop
    } else if ( shows[i].day != null ) { // The show just happens one day a week
        if ( shows[i].day < nowDayOfWeek ) { 
          diff = nowDayOfWeek - shows[i].day + (7 * j); 
          //thisWeek = true;
        } else if ( shows[i].day > nowDayOfWeek ) {
          //thisWeek = false;
          diff = nowDayOfWeek + 7 - shows[i].day + (7 * j); // the show aired last week
        } else { // the show aired today
          if ( kTownTime > shows[i].day * 10000 + shows[i].end + 40 ) {
            //thisWeek = true;
            diff = nowDayOfWeek - shows[i].day + (7 * j);
          } else {
            //thisWeek = false;
            diff = nowDayOfWeek + 7 - shows[i].day + (7 * j);
          }
        }
        displayShow( thisWeek, diff, shows[i] );
      } else { // here we deal with cases when a show airs multiple days a week
        // find the most recent - finished - episode. Start by checking today and move back in time.
        for (var k = 6; k >= 0; k--) {
          if ( shows[i].days.indexOf(k) != -1 ) {
            if ( nowDayOfWeek == k ) {
              var index = shows[i].days.indexOf(k);
              if ( kTownTime > shows[i].days[index] * 10000 + shows[i].end + 42 ) {
                //Today's show is already passed 
                thisWeek = ( j == 0 ) ? true : false ;
                diff = ( j == 0) ? 0: 7 * j  ;   
                displayShow( thisWeek, diff, shows[i] );
              } else {
                // Show the show from a week ago
                thisWeek = false;
                diff = ( j == 0) ? 7  : 7 * j ;
                displayShow( thisWeek, diff, shows[i] );
              }
            } else if ( k < nowDayOfWeek ) {   
              thisWeek = ( j == 0 ) ? true : false ;
              diff = nowDayOfWeek - k + ( 7 * j ) ; 
              displayShow( thisWeek, diff, shows[i] ); 
            } else if ( k > nowDayOfWeek && j != 0 ) { 
              thisWeek = false;
              diff = nowDayOfWeek - k + (7 * j) ;
              displayShow( thisWeek, diff, shows[i] );
            }
          }   
        }
      } 
  }
  // After the loop is done executing, insert the show info in the subHeading div
  var subHeading = document.getElementById("subHeading"); 
  var showInfoText;
    if ( shows[i].biweekly != null ) { // The show happens every other week
      showInfoText = "Biweekly on " + weekDay[shows[i].day] + "s, ";
    } else if ( shows[i].day != null ) { // The show happens once a day
        showInfoText = weekDay[shows[i].day] + "s, ";
    } else if ( shows[i].days && shows[i].days.length == 2 ) {
      showInfoText = weekDay[shows[i].days[0]] + "s and " + weekDay[shows[i].days[1]] + "s, ";
    } else {
      // check if all the values in days[] are consecutive
      var count = null;
      var consecutive = true;
      for (var m = 0; m < shows[i].days.length; m++) {
        if ( count == null ) { count = shows[i].days[m]; }
        else { 
          if ( count != shows[i].days[m] - 1 ) { // they're not consecutive!
            consecutive = false;
          }
          count = shows[i].days[m];
        }
      }
      if ( consecutive ) { 
        showInfoText = weekDay[shows[i].days[0]] + " to " + weekDay[shows[i].days[shows[i].days.length-1]] + ", ";
      }
    }
    
    // Now get the start time and end time
    var startClock = "AM";
    var endClock = "AM";
    var startHour = Math.floor( shows[i].start / 100 );
    if (startHour > 12 ) {
      startHour = startHour % 12;
      startClock = "PM";
    } 
    //startHour = ( startHour < 10 ) ? startHour + "0": startHour;
    var startMinutes = shows[i].start % 100;
    startMinutes = ( startMinutes < 10 ) ? startMinutes + "0" : startMinutes ;
    var endHour = Math.floor( shows[i].end / 100 );
    if ( endHour > 12 ) {
      endHour = endHour % 12;
      endClock = "PM";
    }
      //endHour = ( endHour < 10 ) ? endHour + "0": endHour;
    var endMinutes;
    if ( shows[i].end % 100 == 29 ) {
        endMinutes = 30;
    } else {
        endMinutes = 0;
      endHour++;
    } 
    endMinutes = ( endMinutes < 10 ) ? endMinutes + "0" : endMinutes ;
    var time = startHour + ":" + startMinutes + startClock + " - " + endHour + ":" + endMinutes + endClock;
    showInfoText += time;
  var t = document.createTextNode(showInfoText);
  subHeading.appendChild(t);
    
  }
} 