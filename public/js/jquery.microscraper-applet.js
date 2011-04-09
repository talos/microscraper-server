/**
*
* JavaScript to handle interactions with the MicroScraper Applet.
*
* Depends upon jquery.spinner.
*
**/

(function( $ ) {
    // Singleton applet.
    var applet,
    ns = 'microscraper_applet',
    settings = {
	width : "0",
	height : "0",
	id : ns,
	test : 'Test',
	stop : 'Stop'
    };
    
    methods = {
	init : function(options) {
	    if(!options.code || !options.archive || !options.codebase) {
		$.error('Must specify code, archive, and codebase options.');
	    }
	    
	    options = $.extend(settings, options);
	    
	    // Initialize singleton applet. Locks thread?
	    // TODO : this should be moved to point of first scrape, rather than at initialization
	    if(applet === null) {
		var $applet = $('<applet>').attr({
		    archive : options.archive,
		    codebase : options.codebase,
		    code : options.code,
		    id : options.id,
		    width : options.width,
		    height : options.height
		});
		$('body').append($applet);
		applet = $body.children('applet').get(0);
	    }
	    
	    return this.each(function() {
		if($(this).is('form')) {
		    // Test to see if this is already initialized.  Do nothing if it is.
		    if(!$(this).data(ns)) {
			var data = {};
			$(this).data(ns, data);
			
			data.applet = applet;
			data.elems = {
			    // Add Test button
			    test : $('<button />').attr('type', 'submit').text(options.test),
			    
			    // Add Stop button
			    stop : $('<button />').attr('type', 'button').text(options.stop),
			    
			    log : $('<div />'),
			    results : $('<div />')
			};
			
			$(this)
			    .append(data.elems.results)
			    .append(data.elems.test)
			    .append(data.elems.log)
			    .append(data.elems.log);
		    }
		}
	    });
	},
	
	scrape : function(options) {
	    return this.each(function() {
		var url = $(this)
	    });
	},

	destroy : function(options) {
	    return this.each(function() {
		var data = $(this).data(ns);

		// If initialized, remove child elements & data.
		if(data) {
		    $.each(data.elems, function() {
			$(this).remove();
		    });
		    data = null;
		}
	    });
	}
    };
    
    $.fn[ns] = function(method) {
	if ( methods[method] ) {
	    return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
	} else if ( typeof method === 'object' || ! method ) {
	    return methods.init.apply( this, arguments );
	} else {
	    $.error( 'Method ' +  method + ' does not exist in' + ns + '.' );
	}
    };
}) ( jQuery );

// $('form.test').submit(function(event) {
    // 	var $form = $(this),
    // 	json_location = $form.attr('action');

    // 	$form.spinner( { img : data.spinner_img } );

    // 	var defaults = $form.serializeArray();
    
    //try {
    
    // Function for logging scraper output.
    //var runScraper = setInterval(function() {
    // 	var $log = $form.children('log'),
    // 	line = data.applet.log();
    // 	console.log(line);
    // 	if(line != null) {
    // 	    $log.append(line);
    // 	}
    //     }, 100);

    //     var scraperResults = function ( ) {};
    
    //     // The applet will throw TypeErrors until it's ready.
    //     var tryScraper = function() {
    
    // 	try {
    // 	    console.log(data.applet.isAlive());
    // 	    if(data.applet.isAlive() == false) {
    // 		data.applet.start(json_location, defaults);
    // 		console.log(json_location);
    // 		console.log(defaults);
    // 		$('button[type=submit]', $form).attr('disabled', 'disabled');
    // 		runScraper();
    // 	    }
    // 	} catch(error) {
    // 	    console.log(error);
    // 	    if(error instanceof TypeError) {
    // 		//setTimeout(tryScraper, 100);
    // 	    } else {
    // 		$form.spinner('remove');
    // 		// $.error(error);
    // 		throw error;
    // 	    }
    // 	}
    //     }
    
    //     tryScraper();
    
    //     return false;
    // } catch(error) {
    //     $form.spinner('remove');
    //     event.preventDefault();
    //     $.error(error);
    // }