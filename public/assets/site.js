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
    $(tab).className = "current";
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
    //get all the comments links on the page
    links = $A($$('span.comment_link'));
    for(var i=0; i < links.length; ++i)
    {
        links[i].addEvent('click', function(e) 
        {
            //get the hidden area
            area = e.target.getParent().getParent().getElement('div.comments_container');
            if(area.style.display == "")
            {
                e.target.set("text", "(Show)");
                area.style.display = "none";
            }
            else
            {
                e.target.set("text", "(Hide)");
                area.style.display = "";
            }
        })
    }
}
)