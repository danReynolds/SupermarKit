var RecipeHelper = {
    renderRatings: function(ratingValue) {
        var rating = [];
        for (let x = 0; x < Math.floor(ratingValue); x++) {
            rating.push(
                <i className='material-icons'>star_rate</i>
            );
        }

        if (Math.floor(ratingValue) !== ratingValue) {
            rating.push(
                <i className='material-icons'>star_half</i>
            );
        }

        return rating;
    },

    recipeTime: function(seconds) {
        return 'Time: ' + parseFloat(seconds / 60).toFixed(2) + ' min';
    }
}
