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
    $(tab).className = "selected-tab";
}

function verifyValue(element_id)
{
    elem = $(element_id);
    if(elem.value == null || elem.value == "")
    {
        alert("Please enter a search value.");
        return false;
    }
    else if(elem.value.length < 4)
    {
        alert("The search value must be at least 4 characters.");
        return false;
    }
    return true;
}

window.addEvent("domready", function() 
{
    headers = $A($$('h3.comments_header'));
    for(var i=0; i < headers.length; ++i)
    {
        notice = headers[i].getParent().getElement('span.notice');
        headers[i].addEvent('click', function(e) 
        {
            area = e.target.getParent().getElement('div.comments_container');
            if(area.style.display == "")
            {
                notice.set("text", "(Click to show)");
                area.style.display = "none";
            }
            else
            {
                notice.set("text", "(Click to hide)");
                area.style.display = "";
            }
        })
    }
}
)