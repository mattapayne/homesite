function setCursor()
{
    if(document.body && document.body.getElements)
    {
        alert("Browser supports getting elements by class");
    }
    else
    {
        alert("Browser does not support gettin elements by class");
    }
    elem = document.body.getElements("*[class=select]");
    if(elem)
    {
        alert("Got elem");
    }
    
    if(elem && elem.length && elem[0] && elem[0].focus)
    {
        elem[0].focus();
    }
    else if(elem && elem.focus)
    {
        elem.focus;
    }
}

function setSelectedTab(tab)
{
    $(tab).className = "selected-tab";
}