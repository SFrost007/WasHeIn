$(document).on("pagebeforeshow", "#resultsPage", function(e, ui) {
	$('#showName1').text($('#selection1').attr('data-imdb-title'));
	$('#showName2').text($('#selection2').attr('data-imdb-title'));
	$('#resultList').html('');
});

$(document).on("pageshow", "#resultsPage", function(e, ui) {
	// Show the spinner
	$.mobile.loading('show', {
		text: 'searching',
		textVisible: true,
		theme: 'a'
	});
	
	var showsToFetch = [];
	$('.selectedResult').each(function(i, elem){
		showsToFetch.push({
			'id': $(elem).attr('data-imdb-id'),
			'title': $(elem).attr('data-imdb-title'),
			'cast': [],
			'complete': false
		});
	});

	$.each(showsToFetch, function(i, show){
		var theUrl = "http://m.imdb.com/title/" + show.id + "/fullcredits/cast";
		$.get(theUrl, function(data){

			// Scrape the cast table from the returned data
			$('.col-xs-12.col-md-6', $(data)).each(function(i, elem){
				var actorName = $('h4', elem).text().trim();
				if (!actorName.length) {
					return true;
				}

				var charText = $('p.h4.unbold', elem).text();
				if (charText.indexOf('(') != -1) {
					charText = charText.substr(0, charText.indexOf('('));
				}
				if (charText.indexOf('/') != -1) {
					charText = charText.substr(0, charText.indexOf('/'));
				}
				
				var thumbURL = $('img', elem).attr('src').replace(/SX(\d\d)_SY(\d\d)/g, "SX100_SY110");
				if (thumbURL.substr(0,1) == '/') {
					thumbURL = 'http://m.imdb.com' + thumbURL;
				}
				
				var link = $('a', elem).attr('href');
				if (link.indexOf('?') != -1) {
					link = link.substr(0, link.indexOf('?'));
				}
				if (link.substr(0,2) == '//') {
					link = 'http:' + link;
				}

				show.cast.push({
					'name' : actorName,
					'char' : charText.trim(),
					'link' : link,
					'thumb' : thumbURL
				});
			});
			show.complete = true;

			// Check whether all shows have completed scraping
			var allComplete = true;
			$.each(showsToFetch, function(i, show){
				allComplete &= show.complete;
			});

			// Find people in all shows
			if (allComplete) {
				var appearanceCount = {};
				$.each(showsToFetch, function(i, show){
					$.each(show.cast, function(j, actor){
						if (!appearanceCount[actor.link]) {
							appearanceCount[actor.link] = {
								'count': 1,
								'name': actor.name,
								'char': actor.char,
								'link': actor.link,
								'thumb': actor.thumb
							};
						} else {
							appearanceCount[actor.link].count++;
							appearanceCount[actor.link].char += ', ' + actor.char;
						}
					});
				});

				var matches = [];
				for (var key in appearanceCount) {
					var actor = appearanceCount[key];
					if (actor.count == showsToFetch.length) {
						matches.push(actor);
					}
				}

				var html = '';
				if (matches.length) {
					$.each(matches, function(i, actor){
						html += '<li>'
							+ '<a href="' + actor.link + '" target="_blank">'
							+ '<img src="' + actor.thumb + '"/>'
							+ '<h3>' + actor.name + '</h3>'
							+ '<p>' + actor.char + '</p></a></li>';
					});
				} else {
					html += '<li>No matches</li>';
				}
				$('#resultList').html(html);
				$('#resultList').listview( "refresh" );
				$('#resultList').trigger( "updatelayout");

				$.mobile.loading('hide');
			}
		});
	});
});