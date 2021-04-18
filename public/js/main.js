var loginBtn = document.querySelector(".loginButton") 
var loginScreen = document.querySelector(".loginScreen")
var signupBtn = document.querySelector(".signupButton") 
var signupScreen = document.querySelector(".signupScreen")
var fadeLayer = document.querySelector(".fadeLayer")
var linkTimeout = document.querySelector(".tooMany")
try{
    loginBtn.addEventListener("click", function(){
        loginScreen.classList.remove("hide")
        signupScreen.classList.add("hide")
    });
}catch(e){console.log(e)}
try{
    signupBtn.addEventListener("click", function(){
        signupScreen.classList.remove("hide")
        loginScreen.classList.add("hide")
    });
}catch(e){console.log(e)}
try{
    fadeLayer.addEventListener("click", function(){
        console.log("hiding shit")
        signupScreen.classList.add("hide")
        loginScreen.classList.add("hide")
    })
}catch(e){console.log(e)}
try{
    setTimeout(() => {
        linkTimeout.classList.remove("hide")
    }, 30000)
}catch(e){console.log(e)}
