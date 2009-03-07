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

function showCommentPopup(e)
{
	resetCommentButtons();
	clearPopupContents();
	centrePopup();
	$('comment_popup').setStyle({display : ""});
}

function centrePopup()
{
	var popup = $('comment_popup');
	var popupDimensions = popup.getDimensions();
	var browserDimensions = document.body.getDimensions();
	var y = (browserDimensions.height - popupDimensions.height) / 2;
	var x = (browserDimensions.width - popupDimensions.width) / 2;
	popup.setStyle({top: y + "px", left: x + "px"});
}

function clearPopupContents()
{
	$('comment_errors').update("");
	$("comment_success").update("");
	$('_textarea').value = "";
	$('_email').value = "";
	$('_website').value = "";
	$('_username').value = "";
}

function hideCommentPopup()
{
	$('comment_popup').setStyle({display:"none"});
}

function registerCommentLinks()
{
	//get all the comments links on the page
    links = $A($$('span.comment_link'));
	if(links != null && links.length != 0)
	{
    	for(var i=0; i < links.length; ++i)
	    {
	        links[i].observe('click', function(e) 
	        {
	            //get the hidden area
	            area = $(e.target).up('div.post_comments').down('div.comments_container');
	            if(area.style.display == "")
	            {
	                e.target.update("(Show)");
	                area.setStyle({display: "none"});
	            }
	            else
	            {
	                e.target.update("(Hide)");
	                area.setStyle({display: ""});
	            }
	        })
	    }
	}
}

function registerAddCommentLinks()
{
	add_links = $A($$('a.add_comment_link'));
	if(add_links != null && add_links.length != 0)
	{
		for(var i=0; i<add_links.length; i++)
		{
			add_links[i].observe('click', function(e) {
				postId = e.target.id;
				$('_post_id').value = postId;
				showCommentPopup(e);
				return false;
			});
		}
	}
}

function setupButtons()
{
	cancelButton = $('cancel_button');
	if(cancelButton != null)
	{
		cancelButton.observe("click", function() { hideCommentPopup(); });
	}
	submit_button = $('submit_comment_button');
	if(submit_button)
	{
		submit_button.observe("click", function() {
			var errors = validateComment();
			if(errors == null || errors.length == 0)
			{
				submitComment();
			}
			else
			{
				var errorsHTML = generateCommentErrorMessages(errors);
				$('comment_errors').update(errorsHTML);
			}
		});
	}
	closeButton = $('close_button');
	if(closeButton)
	{
		closeButton.observe("click", function() {
			hideCommentPopup();
		});
	}
}

function submitComment()
{
	var comment = getCommentFields();
	
	new Ajax.Request('/blog/create/comment', {
		method: "POST",
		parameters: {
			post_id: comment.post_id,
			username: comment.username,
			email: comment.email,
			website: comment.webaddress,
			comment: comment.comment
		},
		onFailure: function(transport) { 
			setCommentErrorMessage(transport.responseText);
			 },
		onSuccess: function(transport) {
			setCommentSubmittedSuccessfully(transport.responseText);
		}
	})
}

function setCommentErrorMessage(errorMessageJSON)
{
	$('comment_success').update("");
	var messages = errorMessageJSON.evalJSON();
	var text = generateCommentErrorMessages(messages)
	$('comment_errors').update(text);
}

function setCommentButtonsForCommentSubmitted()
{
	var cancel_button = $('cancel_button');
	if(cancel_button)
	{
		cancel_button.value = "Close";
	}
	var submit_button = $('submit_comment_button');
	if(submit_button)
	{
		submit_button.hide();
	}
}

function resetCommentButtons()
{
	var cancel_button = $('cancel_button');
	if(cancel_button)
	{
		cancel_button.value = "Cancel";
	}
	var submit_button = $('submit_comment_button');
	if(submit_button)
	{
		submit_button.show();
	}
}

function generateCommentErrorMessages(errors_array)
{
	var errorsHTML = "<div style='font-weight:bold;'>Your comment contained errors:</div>";
	errorsHTML += "<ul>";
	for(var i=0; i<errors_array.length; i++)
	{
		errorsHTML += "<li>" + errors_array[i] + "</li>";
	}
	errorsHTML += "</ul>";
	return errorsHTML;
}

function setCommentSubmittedSuccessfully(messageJSON)
{
	$('comment_errors').update("");
	setCommentButtonsForCommentSubmitted();
	var messages = messageJSON.evalJSON();
	var text = generateCommentMessages(messages);
	$("comment_success").update(text);
}

function generateCommentMessages(messages_array)
{
	var msgHTML = "<div style='font-weight:bold;'>Your comment was submitted successfully:</div>";
	msgHTML += "<ul>";
	for(var i=0; i<messages_array.length; i++)
	{
		msgHTML += "<li>" + messages_array[i] + "</li>";
	}
	msgHTML += "</ul>";
	return msgHTML;
}

function getCommentFields()
{
	var comment = new Object();
	comment.username = $('_username').value;
	comment.email = $('_email').value;
	comment.webaddress = $('_website').value;
	comment.comment = $('_textarea').value;
	comment.post_id = $('_post_id').value;
	return comment;
}

function validateComment()
{
	var comment_fields = getCommentFields();
	var errors = new Array();
	
	if(comment_fields.username == null || comment_fields.username.length == 0)
	{
		errors.push("You must supply your name.");
	}
	if(comment_fields.webaddress != null && comment_fields.webaddress.length > 0 
		&& !validUrl(comment_fields.webaddress))
	{
		errors.push("Please supply a valid url for your web address.");
	}
	if(comment_fields.email != null && comment_fields.email.length > 0 
		&& !validEmail(comment_fields.email))
	{
		errors.push("Please supply a valid email address.");
	}
	if(comment_fields.comment == null || comment_fields.comment.length == 0)
	{
		errors.push("Please supply a comment.");
	}
	return errors;
}

function validEmail(email)
{
	var filter = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
	return filter.test(email);
}

function validUrl(url)
{
	var regexp = /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
	return regexp.test(url);
}

function setupPopup()
{
	new Draggable('comment_popup', {
		handle : 'popup_top',
		scroll : window
	})
}

document.observe("dom:loaded", function() {
    registerCommentLinks();	
	registerAddCommentLinks();
	setupPopup();
	setupButtons();
	}
)