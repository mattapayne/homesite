function setCursor()
{
    var elem = null;
    
    if(document.body && document.body.getElements)
    {
        elem = document.body.getElements("*[class=select]");
    }
    else
    {
        return;
    }
    
    if(elem && elem.length && elem[0] && elem[0].focus)
    {
        elem[0].focus();
    }
}

function unloadMap()
{
    GUnload();
}

function setSelectedTab(tab)
{
    if(tab && $(tab))
    {
        $(tab).className = "current";
    }
}