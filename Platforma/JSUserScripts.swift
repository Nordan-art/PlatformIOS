//
//  JSUserScripts.swift
//  MIACRM
//
//  Created by Danik on 8.01.23.
//
import Foundation

let getDataL  = """
document.getElementById('triggerAppKey').value="IOS";
"""

let endAnimationLoad = """
setTimeout(()=>window.location.reload(), 3000);
"""

let endAnimationOnClose = """
window.location.reload()
"""

let LoadNewPageAfterPayment = """
setTimeout(()=>window.location.href = 'https://crm.mcgroup.pl/ticket_description', 3000);
"""

let LoadNewPageAfterPaymentAccountant = """
setTimeout(()=>window.location.href = 'https://crm.mcgroup.pl/my-accountant', 2000);
"""

let setDataLJS  = """
var swiftIdBan = document.querySelector('.startBoxBanner').id;
var swiftSceneElm = document.querySelector('#'+swiftIdBan+'> .HYPE_scene[style*="block"]');
document.addEventListener('click', (e)=>{
    if(e.target.classList.contains('btn-login')){
        localStorage.setItem("datalcrm", btoa(swiftSceneElm.querySelector('.login-email').value));
        localStorage.setItem("datapcrm", btoa(swiftSceneElm.querySelector('.login-password').value));
    }
})
"""

let getDataLJS  = """
document.getElementById('triggerAppKey').value="macOS";

if(localStorage.getItem('datalcrm')){
    var ll = localStorage.getItem('datalcrm');
    var pp = localStorage.getItem('datapcrm');
    var swiftIdBan = document.querySelector('.startBoxBanner').id;
    var swiftSceneElm = document.querySelector('#'+swiftIdBan+'> .HYPE_scene[style*="block"]');
    swiftSceneElm.querySelector('.login-email').value = atob(ll);
    swiftSceneElm.querySelector('.login-password').value = atob(pp);
}
"""
