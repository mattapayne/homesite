function setCursor()
{
    elem = document.body.getElements("*[class=select]");
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