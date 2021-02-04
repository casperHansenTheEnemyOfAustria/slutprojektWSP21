var loginBtn = document.querySelector(".loginButton") 
var loginScreen = document.querySelector(".loginScreen")
var signupBtn = document.querySelector(".signupButton") 
var signupScreen = document.querySelector(".signupScreen")


loginBtn.addEventListener("click", function(){
    loginScreen.classList.remove("hide")
    signupScreen.classList.add("hide")
});
signupBtn.addEventListener("click", function(){
    signupScreen.classList.remove("hide")
    loginScreen.classList.add("hide")
});