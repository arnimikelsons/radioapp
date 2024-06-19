// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
/* Audio Player Scripts */

  // Set global variables for Play button, playing and pausing functionality
  var music = document.getElementById('music');  // id for audio element
  var pButton = document.getElementById('pButton'); // id for play toggle button
  var playBtn = document.getElementById('player-play'); // id for play icon
  var pauseBtn = document.getElementById('player-pause'); // id for pause
  
  // play button event listenter
  if (pButton !== null) {
    pButton.addEventListener("click", play);
  }

  // Play and Pause
  function play() {
    console.log("play button clicked");
    // start music
    if (music.paused) {
      music.play();
      //remove play, add pause
      playBtn.style.display = "none";
      pauseBtn.style.display = "block";
    } else {  // pause music
      music.pause();
      // remove pause, add play
      playBtn.style.display = "block";
      pauseBtn.style.display = "none";
    }
  }
  
  // Set global variable for volume input range slider
  let savedVolume = 1.0;
  const volume = document.querySelector("#volume");
  const muteControl = document.querySelector("#muteControl");
  let isMuted = false;
  
  function unMute() {
      isMuted = false;
          muteControl.innerHTML = `
          <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" fill="currentColor" class="bi bi-volume-up-fill" viewBox="0 0 16 16">
              <path d="M11.536 14.01A8.473 8.473 0 0 0 14.026 8a8.473 8.473 0 0 0-2.49-6.01l-.708.707A7.476 7.476 0 0 1 13.025 8c0 2.071-.84 3.946-2.197 5.303l.708.707z"/>
              <path d="M10.121 12.596A6.48 6.48 0 0 0 12.025 8a6.48 6.48 0 0 0-1.904-4.596l-.707.707A5.483 5.483 0 0 1 11.025 8a5.483 5.483 0 0 1-1.61 3.89l.706.706z"/>
              <path d="M8.707 11.182A4.486 4.486 0 0 0 10.025 8a4.486 4.486 0 0 0-1.318-3.182L8 5.525A3.489 3.489 0 0 1 9.025 8 3.49 3.49 0 0 1 8 10.475l.707.707zM6.717 3.55A.5.5 0 0 1 7 4v8a.5.5 0 0 1-.812.39L3.825 10.5H1.5A.5.5 0 0 1 1 10V6a.5.5 0 0 1 .5-.5h2.325l2.363-1.89a.5.5 0 0 1 .529-.06z"/>
          </svg>
      `;
  }
  
  function mute() {
      isMuted = true;
      muteControl.innerHTML = `
      <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" fill="currentColor" class="bi bi-volume-mute-fill" viewBox="0 0 16 16">
          <path d="M6.717 3.55A.5.5 0 0 1 7 4v8a.5.5 0 0 1-.812.39L3.825 10.5H1.5A.5.5 0 0 1 1 10V6a.5.5 0 0 1 .5-.5h2.325l2.363-1.89a.5.5 0 0 1 .529-.06zm7.137 2.096a.5.5 0 0 1 0 .708L12.207 8l1.647 1.646a.5.5 0 0 1-.708.708L11.5 8.707l-1.646 1.647a.5.5 0 0 1-.708-.708L10.793 8 9.146 6.354a.5.5 0 1 1 .708-.708L11.5 7.293l1.646-1.647a.5.5 0 0 1 .708 0z"/>
      </svg>
      `;
  }
  
  function lowVolume() {
    isMuted = false;
    muteControl.innerHTML = `
                <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" fill="currentColor" class="bi bi-volume-down-fill" viewBox="2 0 16 16">
                  <path d="M9 4a.5.5 0 0 0-.812-.39L5.825 5.5H3.5A.5.5 0 0 0 3 6v4a.5.5 0 0 0 .5.5h2.325l2.363 1.89A.5.5 0 0 0 9 12V4zm3.025 4a4.486 4.486 0 0 1-1.318 3.182L10 10.475A3.489 3.489 0 0 0 11.025 8 3.49 3.49 0 0 0 10 5.525l.707-.707A4.486 4.486 0 0 1 12.025 8z"/>
                </svg>
    `;
  }
  function highVolume() {
    isMuted = false;
    muteControl.innerHTML = `
          <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" fill="currentColor" class="bi bi-volume-up-fill" viewBox="0 0 16 16">
              <path d="M11.536 14.01A8.473 8.473 0 0 0 14.026 8a8.473 8.473 0 0 0-2.49-6.01l-.708.707A7.476 7.476 0 0 1 13.025 8c0 2.071-.84 3.946-2.197 5.303l.708.707z"/>
              <path d="M10.121 12.596A6.48 6.48 0 0 0 12.025 8a6.48 6.48 0 0 0-1.904-4.596l-.707.707A5.483 5.483 0 0 1 11.025 8a5.483 5.483 0 0 1-1.61 3.89l.706.706z"/>
              <path d="M8.707 11.182A4.486 4.486 0 0 0 10.025 8a4.486 4.486 0 0 0-1.318-3.182L8 5.525A3.489 3.489 0 0 1 9.025 8 3.49 3.49 0 0 1 8 10.475l.707.707zM6.717 3.55A.5.5 0 0 1 7 4v8a.5.5 0 0 1-.812.39L3.825 10.5H1.5A.5.5 0 0 1 1 10V6a.5.5 0 0 1 .5-.5h2.325l2.363-1.89a.5.5 0 0 1 .529-.06z"/>
          </svg>    
    `;
  }
  
  if (volume !== null) {
    volume.addEventListener("input", () => {
        music.volume = volume.value; 
        savedVolume = volume.value;
        if (isMuted) {
            unMute();
        }
        if (volume.value > 0.0 && volume.value <= 0.5) {
          lowVolume();
        }
        if (volume.value >= 0.6 ) {
          highVolume();
        }
        if (volume.value == 0.0) {
            mute();
        }
    });
  }
  
  if (muteControl !== null) {
    muteControl.addEventListener("click", () => {
        if (isMuted) {
          // Unmute the stream
          music.volume = savedVolume;
          volume.value = savedVolume;
          unMute();
        } else {
            // Mute the stream
            music.volume = 0.0;
            volume.value = 0.0;
            mute();
        }
    });
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
    // hooks: Hooks,
    params: {_csrf_token: csrfToken}
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.delayedShow(200))
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

/****
 * 
 * 
 * INDIVIDUAL PROGRAM PAGES ARCHIVE DISPLAY CODE
 * 
 * 
 ****/

// function displayShow accepts the diff argument which is the time difference between now and the day of the show 
// to display on the screen. If it's the most recent airing, it also creates the audio player in the <audio> tag
// this function is called 8 times in order to show the last 8 episodes. each time it is called with a different diff value
// representing the difference between now and the date of the show to display
function displayShow( week, diff, startTime, runTime ) { 
  d = new Date();
  d.setDate( d.getDate() - diff );
  d.setHours( startTime );
  var divName = ( week ) ? "thisWeek" : "lastWeek";
  var year = d.getFullYear();
  var moy = d.getMonth() + 1;
  moy = ( moy < 10 ) ? "0" + moy : moy;
  var dom = d.getDate();
  dom = ( dom < 10 ) ? "0" + dom : dom;
  var hour = d.getHours();
  hour = ( hour < 10 ) ? "0" + hour : hour;
  // is the show more than an hour long? Then grab both files. what if a show is 3 hours long?
  var length = runTime;
  var minutes;
  var topOfHour = true;
  var downloadText;
  console.log("length: ", length);
  
  if ( length <= 30 ) { minutes = 30; downloadText = "Download file";  }
  else if ( length < 70 ) { minutes = 60; downloadText = "Download file";  }
  else if ( length < 130 ) { minutes = 120; downloadText = "Hour 1"; }
  else { minutes = 180; downloadText = "Hour 1"; }
  
  if ( startTime % 100 == 30 ) { 
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
      node.currentTime=1800;
    } 
    
    var sourceNode = document.createElement("source");
    sourceNode.setAttribute("src", "https://audio.cfrc.ca/archives/"+ year + "-" + moy + "-" + dom + "-" + hour + ".mp3" );
    sourceNode.setAttribute("type", "audio/mpeg");
    node.appendChild(sourceNode);
    // Append everything inside the music player container
    var musicPlayer = document.getElementById("music2Container");  
    
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
var page = document.getElementById("pageShowTitle");
var latestEpisodePlayer = false; // record whether the archive audio player has already been created

// Here's where the execution begins

if (page !== null) { // this is a show.html.heex template, and therefore must display program archives

  // Declare your variables first
  var d = new Date();
  var diff = 0; // Store the difference between today's date and the date the show aired last
  var nowDayOfWeek = d.getDay(); // Sunday = 0, Saturday = 6
  var nowInteger = d.getDay() * 10000 + d.getHours() * 100 + d.getMinutes();
  //var offsetAmount = d.getTimezoneOffset() / 60 * 100;
  //var kTownTime = nowInteger + offsetAmount - 500;
  var kTownTime = nowInteger;
  var thisWeek = false; // boolean value to know if we're displaying shows from this week or last
  var month = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
  var weekDay = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];   
  
  // Get values from phoenix
  let timeslotDays = Array.from(document.querySelectorAll('.timeslotDayInt'));
  let startTimes = Array.from(document.querySelectorAll('.timeslotStartTime'));
  let runTimes = Array.from(document.querySelectorAll('.timeslotRunTime'));

  let numTimeSlots = parseInt(document.getElementById("numberOfTimeslots").innerHTML);
  let dayOfShow;
  if ( timeslotDays != null ) { dayOfShow = timeslotDays[0].innerHTML; } // get the day of week from 0 to 6
  let startTime;
  if ( startTimes != null ) { startTime = parseInt(startTimes[0].innerHTML.substring(0,2)); } // get the start time
  let runTime;
  if ( runTimes != null ) { runTime = parseInt(runTimes[0].innerHTML); }  // get the show length

  // Calculate end of show time
  let showEndTime = dayOfShow * 10000;
  showEndTime += startTime * 100 + runTime;
  let timeSlots = timeslotDays.map(timeslot => parseInt(timeslot.innerHTML)); // Get an array of weekdays e.g. [4, 6]
  startTimes = startTimes.map(startTime => parseInt(startTime.innerHTML.substring(0,2)));
  runTimes = runTimes.map(runTime => parseInt(runTime.innerHTML));

  // Look 8 times to output 8 most recent episodes
  for ( var j = 0; j < 8; j++ ) { 
    if ( numTimeSlots == 1 ) { // The show just happens one day a week

      if ( dayOfShow < nowDayOfWeek ) { 
        diff = nowDayOfWeek - dayOfShow + (7 * j); 
      } else if ( dayOfShow > nowDayOfWeek ) {
        diff = nowDayOfWeek + 7 - dayOfShow + (7 * j); // the show aired last week
      } else { // the show aired today
        if ( kTownTime > showEndTime ) { // if the show has ended
          diff = nowDayOfWeek - dayOfShow + (7 * j);
        } else { // the show has not yet finished
          diff = nowDayOfWeek + 7 - dayOfShow + (7 * j);
        }
      }
      displayShow( thisWeek, diff, startTime, runTime );

    } else { // here we deal with cases when a show airs multiple days a week
      // find the most recent - finished - episode. Start by checking today and move back in time.

      for (var k = 6; k >= 0; k--) { // Cycle through days of week from Saturday (6) to Sunday (0)
        
        if ( timeSlots.indexOf(k) > -1 ) { // The show aired on this day
          var index = timeSlots.indexOf(k); 

          if ( nowDayOfWeek == k ) { // It aired today
            if ( kTownTime > timeSlots[index] * 10000 + startTimes[index] * 100 + runTimes[index]) {

              // Today's show is already passed, display today's episode
             console.log("Today's show is already passed, display today's episode");
              thisWeek = ( j == 0 ) ? true : false ;
              diff = ( j == 0) ? 0: 7 * j  ; 
             
              displayShow( thisWeek, diff, startTimes[index], runTimes[index] );
            } else {

              // Show the episode from a week ago
              thisWeek = false;
              diff = ( j == 0) ? 7  : 7 * j ;
              displayShow( thisWeek, diff, startTimes[index], runTimes[index] );
            }
          } else if ( k < nowDayOfWeek ) {   
            thisWeek = ( j == 0 ) ? true : false ;
            diff = nowDayOfWeek - k + ( 7 * j ) ; 
            displayShow( thisWeek, diff, startTimes[index], runTimes[index] ); 
          } else if ( k > nowDayOfWeek && j != 0 ) { 
            thisWeek = false;
            diff = nowDayOfWeek - k + (7 * j) ;
            displayShow( thisWeek, diff, startTimes[index], runTimes[index] );
          }
        }   
      }
    } 
  }
}
/**** 
 * 
 * 
 * ARCHIVES PAGE jQUERY CODE
 * 
 * ****/

// MUST WRAP THE FOLLOWING CODE IN A BLOCK SO IT ONLY EXECUTES ON ARCHIVES PICKER PAGE

let monthStart, dayStart, yearStart, monthCurrent, monthCurrentName, dayCurrent, yearEnd, oneMonthAgoInt, twoMonthsAgoInt, threeMonthsAgoInt, fourMonthsAgoInt, oneMonthAgoName, twoMonthsAgoName, threeMonthsAgoName, fourMonthsAgoName;

function listenSubmit() {
  $('form').submit(event => {
    event.preventDefault();
    // $(".submission_form").hide();
    $(".hidden").show(); // Calculate archive string

    let month = $('#archives_month').val();

    if (month.length === 1) {
      month = "0" + month;
    }

    let baseURL = "https://audio.cfrc.ca/archives/";
    let fileName = baseURL + $('#archives_year').val() + "-" + month + "-" + $('#archives_day').val() + "-" + $('#archives_time').val() + ".mp3"; // Check if the file exists on the server

    fetch(fileName).then(function () {
      // exists code 
      $(".results").html(`
                <p>Please enjoy your selection below:</p>
                <audio controls="controls">
			   	    <source src="${fileName}" type="audio/mpeg" />
			   	    Your browser does not support the audio element.
			    </audio>
			    <p>
                    <a href='${fileName}'>Right-click to download your selection</a>
                </p>
            `);
    }).catch(function () {
      // not exists code
      $(".results").html('<p>Your selection is no longer in our archives.</p>');
    });
  });
}

function fillOutForm() {
  let htmlString = '';

  while (yearStart >= yearEnd) {
    htmlString += `<option value='${yearStart}'>${yearStart}</option>`;

    if (monthCurrent < 4) {
      yearStart = yearStart - 1;
    } else {
      yearStart = yearEnd - 1;
    }
  }

  $("#archives_year").append(htmlString);
  let monthString = `
        <option value='${monthCurrent}'>${monthCurrentName}</option>";
        <option value='${oneMonthAgoInt}'>${oneMonthAgoName}</option>";
        <option value='${twoMonthsAgoInt}'>${twoMonthsAgoName}</option>";
        <option value='${threeMonthsAgoInt}'>${threeMonthsAgoName}</option>";
    `;

  if (dayCurrent < 10) {
    monthString += `<option value='${fourMonthsAgoInt}'>${fourMonthsAgoName}</option>`;
  }

  $("#archives_month").append(monthString);
  let dayString = '';

  while (dayStart < 32) {
    if (dayStart < 10) {
      dayString += `<option value='0${dayStart}'>0${dayStart}</option>`;
      dayStart++;
    } else {
      dayString += `<option value='${dayStart}'>${dayStart}</option>`;
      dayStart++;
    }
  }

  $("#archives_day").append(dayString);
}

function start() {
  // Verify that the General Archives Picker is present in the DOM, otherwise, do not execute the rest
  // of this function conde
  let archives = document.getElementById("archivesContainer");

  if (archives !== null) {
    //Hide the results section
    $(".hidden").hide(); // begin initial calculations

    let now = new Date();
    monthStart = 1;
    dayStart = 1;
    yearStart = now.getFullYear();
    ;
    monthCurrent = now.getMonth() + 1;
    var options = {
      month: 'long'
    };
    monthCurrentName = new Intl.DateTimeFormat('en-US', options).format(now);
    dayCurrent = now.getUTCDate();
    yearEnd = now.getFullYear() - 1;
    let oldDate = new Date(); // create moveable date to get previous month numbers and 

    oldDate.setMonth(oldDate.getMonth(), 0); // go back one month

    oneMonthAgoInt = oldDate.getMonth() + 1; // variable to store last month integer

    oneMonthAgoName = new Intl.DateTimeFormat('en-US', options).format(oldDate); // store last month name

    oldDate.setMonth(oldDate.getMonth(), 0); // go back another month

    twoMonthsAgoInt = oldDate.getMonth() + 1;
    twoMonthsAgoName = new Intl.DateTimeFormat('en-US', options).format(oldDate);
    oldDate.setMonth(oldDate.getMonth(), 0);
    threeMonthsAgoInt = oldDate.getMonth() + 1;
    threeMonthsAgoName = new Intl.DateTimeFormat('en-US', options).format(oldDate);
    oldDate.setMonth(oldDate.getMonth(), 0);
    fourMonthsAgoInt = oldDate.getMonth() + 1;
    fourMonthsAgoName = new Intl.DateTimeFormat('en-US', options).format(oldDate); // fill out the form

    fillOutForm();
    listenSubmit();

  }
}

$(start);

