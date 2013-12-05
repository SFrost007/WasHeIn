$(document).on("pageinit", "#searchPage", function() {
	// Hide the two selected result placeholders
	$(".imdbAutoComplete").next().hide();
	
	// Disable autocorrect for the search fields
	$('input[data-type=search]').attr('autocorrect', 'off');

	$(".imdbAutoComplete").on("listviewbeforefilter", function (e, data) {
		var $ul = $(this);
		var field = $(data.input);
		var value = field.val().toLowerCase();

		if (value && value.length) {
			value = value.replace(' ', '_');
			$.ajax({
				url: "http://sg.media-imdb.com/suggests/" + value.substr(0,1) + "/" + value + ".json",
				dataType: "jsonp",
				jsonp: false,
				jsonpCallback: 'imdb$' + value,
			})
			.done(function (data, textStatus, jqXHR) {
				$ul.html('');
				$.each(data.d, function(i, val) {
					if (val.q == 'TV series' || val.q == 'feature') {

						var $li = $('<li>');
						var $a = $('<a href="#"/>');

						var imgsrc = val.i
								? val.i[0].replace("._V1_.jpg", "._V1._SX80_CR0,0,80,108_.jpg")
								: 'http://i.media-imdb.com/images/mobile/film-40x54.png';

						$a.click(function(){
							var showNum = $ul.attr('id').substr($ul.attr('id').length - 1);

							// Set the elements in the selection result
							var target = '#selection'+showNum;
							$(target).attr({
								'data-imdb-title': val.l,
								'data-imdb-id': val.id
							});
							$(target + ' img').attr('src', imgsrc);
							if (val.y) {
								$(target + ' h3').html(val.l + ' (' + val.y + ')');
							} else {
								$(target + ' h3').html(val.l);
							}
							$(target + ' p').html(val.s ? val.s : '');

							// Hide the result list and its filter box
							$ul.hide();
							$ul.prev().hide();
							$ul.next().show();

							// Clear the old search
							field.val('').trigger("change");

							// Enable the search button if both shows have been chosen
							var show1 = $('#selection1').attr('data-imdb-id');
							var show2 = $('#selection2').attr('data-imdb-id');
							if (show1 && show2 && show1.length && show2.length) {
								$('#searchBtn').removeClass('ui-disabled');
							}
						});

						$a.append('<img src="'+imgsrc+'"/>');
						if (val.y) {
							$a.append('<h3>' + val.l + ' (' + val.y + ')</h3>');
						} else {
							$a.append('<h3>' + val.l + '</h3>');
						}
						$a.append('<p>' + (val.s ? val.s : '') + '</p>');
						
						$li.append($a);
						$ul.append($li);
					}
				});
				$ul.listview( "refresh" );
				$ul.trigger( "updatelayout");
			});
		} else {
			// Empty search, clear the list
			$ul.html('');
		}
	});

	$(".selectedResult").click(function(){
		var elem = $(this);
		var showNum = elem.attr('id').substr(elem.attr('id').length - 1);
		elem.attr({
			'data-imdb-title': '',
			'data-imdb-id': ''
		});
		elem.hide();
		elem.prev().show();
		elem.prev().prev().show();
		$('#searchBtn').addClass('ui-disabled');
	});
});

