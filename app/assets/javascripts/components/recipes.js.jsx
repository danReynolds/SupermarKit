var Recipes = React.createClass({
    mixins: [ModalContainer],

    getInitialState: function() {
        return {
            recipes: []
        }
    },

    componentWillMount: function() {
        $.getJSON(this.props.recipe_url, function(response) {
            this.setState({
                recipes: response.matches
            });
        }.bind(this));
    },

    componentDidUpdate: function(prevProps, prevState) {
        if (this.state.recipes !== prevState.recipes) {
            $(document).ready(function() {
                $('.carousel').carousel({
                    full_width: true,
                    time_constant: 100
                });
            });
        }
    },

    render: function() {
        var carousel_items = this.state.recipes.map(function(recipe, index) {
            return (
                <div
                    key={'carousel-item-' + index}
                    className='carousel-item'>
                    <a href="#">
                        <img src={recipe.smallImageUrls[0].replace('s90', 'l90')} />
                    </a>
                    <div className="caption">
                        <p>{recipe.sourceDisplayName}</p>
                        <p>{'Time: ' + parseFloat(recipe.totalTimeInSeconds / 3600).toFixed(2) + 'hrs'}</p>
                    </div>
                </div>
            );
        });
        return (
            <div className='card recipes'>
                <div className='card-content full-width'>
                    <div className='carousel carousel-slider'>
                        {carousel_items}
                    </div>
                </div>
            </div>
        )
    }
});
