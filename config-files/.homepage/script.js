// Load the config.json file (using JavaScript vanilla)

let clock_text = document.getElementById("clock-text");
let date_text = document.getElementById("date-text");

displayTime();
setInterval(displayTime, 1000);
displayDate();
setInterval(displayDate, 60000);

function displayTime() {
  let date = new Date();
  let hours = date.getHours();
  let minutes = date.getMinutes();
  let ampm = hours >= 12 ? "PM" : "AM";
  hours = hours % 12;
  hours = hours ? hours : 12;
  minutes = minutes < 10 ? "0" + minutes : minutes;
  let time = hours + ":" + minutes + " " + ampm;
  clock_text.innerHTML = time;
}

function displayDate() {
  let date = new Date();
  let days = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];
  let day = days[date.getDay()];
  let dayNumber = date.getDate();
  let month = date.toLocaleString("default", { month: "long" });
  let year = date.getFullYear();

  if (dayNumber == 1 || dayNumber == 21 || dayNumber == 31) {
    dayNumber += "st";
  } else if (dayNumber == 2 || dayNumber == 22) {
    dayNumber += "nd";
  } else if (dayNumber == 3 || dayNumber == 23) {
    dayNumber += "rd";
  } else {
    dayNumber += "th";
  }

  let dateText = day + ", " + dayNumber + " " + month + " " + year;
  date_text.innerHTML = dateText;
}
