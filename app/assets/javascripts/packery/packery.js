//
// Packery
//

$(function(){
// initialize Packery
	var container = document.querySelector('#js-packery');

	// only run if the container exists
	if ($(container).length > 0) {

		// setup
		var pckry = new Packery( container, {
			itemSelector: '.Teaser',
			gutter: '.gutter-sizer',
			columnWidth: '.grid-sizer'
		});

		// layout Packery after all images have loaded
		imagesLoaded( container, function() {
			pckry.layout();
		});
	}
	console.log('hello');
});