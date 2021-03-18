var loginBtn = document.querySelector(".loginButton") 
var loginScreen = document.querySelector(".loginScreen")
var signupBtn = document.querySelector(".signupButton") 
var signupScreen = document.querySelector(".signupScreen")
var fadeLayer = document.querySelector(".fadeLayer")


loginBtn.addEventListener("click", function(){
    loginScreen.classList.remove("hide")
    signupScreen.classList.add("hide")
});
signupBtn.addEventListener("click", function(){
    signupScreen.classList.remove("hide")
    loginScreen.classList.add("hide")
});

fadeLayer.addEventListener("click", function(){
    console.log("hiding shit")
    signupScreen.classList.add("hide")
    loginScreen.classList.add("hide")
})