/**
*
* JavaScript for MicroScraper.
*
**/

$(document).ready(function() {
    /* Allows for PUT and DELETE from forms, reloads upon success. */
    $('form.ajax').each(function() {
	var method = $(this).attr('method');
	$(this).ajaxForm({
	    type : method,
	    success : function() {
		location.reload();
	    },
	    error : function(response, responseText) {
		$.error( responseText );
	    }
	});
    });
    /* Testing. Intercept test form submission and give it to the applet. */
    $('form.test').submit(function(event) {
	try {
	    var json_location = $(this).attr('action'),
	    defaults = $(this).serializeArray();
	    console.log(defaults);
	    console.log(json_location);
	    
	    //var results = $('applet').get(0).scrape(json_location, defaults);
	    //var results = $('applet').get(0).scrape(json_location);
	    
	    //console.log(results);
	    return false;
	} catch(error) {
	    event.preventDefault();
	    $.error(error);
	}
    });
    /* Autofill 'add' inputs, which are used for tagging & resource creation. */
    $('input.add').each(function() {
	var $input = $(this);
	$input.autocomplete({
	    minLength : 1,
	    /* Replace 'term' with the input's name, plus wildcard. */
	    source : function ( request, response ) {
		var term = $input.attr('name'),
		data = {};
		data[term] = '%' + request.term + '%';
		$.ajax({
		    url : $input.attr('title'),
		    dataType : 'json',
		    data : data,
		    success : function ( labels ) {
			console.log(labels);
			response ( labels );
		    },
		    error : function ( response, responseText ) {
			$.error( responseText );
		    }
		});
	    }
	});
    });
    /* Accordion. No longer used.  TODO: remove from UI library. */
    //$('.accordion').accordion({autoHeight: false});
    /* Button. */
    $('button').button();
    /* Tabs. */
    $('.tabs').tabs({
	cookie : {}
    });
});

