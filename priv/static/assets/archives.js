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

$(start);
