var acc = document.getElementsByClassName("accordion");
var i;

/* Click Listener für FAQ */
for (i = 0; i < acc.length; i++) {
  acc[i].addEventListener("click", function () {
    this.classList.toggle("active");
    this.parentElement.classList.toggle("active");

    var panel = this.nextElementSibling;

    if (panel.style.display === "block") {
      panel.style.display = "none";
    } else {
      panel.style.display = "block";
    }
  });
}

var form = document.getElementsByClassName("formcontainer")[0];
var book = document.getElementById("book");

/* Formular öffnen */
function openForm() {
  if (form) {
    form.classList.add("active");
    setTimeout(() => {
      form.scrollIntoView({ behavior: "smooth", block: "center" });
    }, 400);
  }
}

/* Scroll zur 'book'-Section */
function scrollToMore() {
  if (book) {
    book.scrollIntoView({ behavior: "smooth", block: "center" });
  }
}

/* Formular schließen */
function closeForm() {
  if (form && book) {
    form.classList.remove("active");
  }
}

var topnav = document.getElementsByClassName("topnav")[0];
var burgerBtn = document.getElementsByClassName("burgerBtn")[0];

/* Burger Button Menü Toggle */
function toggleBurger() {
  if (topnav) {
    topnav.classList.toggle("active");
    burgerBtn.classList.toggle("active");
  }
}
