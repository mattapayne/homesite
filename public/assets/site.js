function set_cursor()
{
	elem = document.body.getElements("*[class=select]");
	if(elem && elem[0] && elem[0].focus)
	{
		elem[0].focus();
	}
}
