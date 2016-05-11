var Recipes = React.createClass({
    mixins: [_.omit(ModalContainer, 'addToSelection'), RecipeHelper],

    getInitialState: function() {
        return {
            recipes: []
        }
    },

    componentDidMount: function() {
        // $.getJSON(this.props.modal.queryUrl, function(response) {
            this.setState({
                recipes: [
                    {
                        "attributes": {
                            "course": [
                                "Main Dishes",
                                "Soups"
                            ]
                        },
                        "flavors": {
                            "salty": 0.6666666666666666,
                            "sour": 0.6666666666666666,
                            "sweet": 0.3333333333333333,
                            "bitter": 0.16666666666666666,
                            "meaty": 0.3333333333333333,
                            "piquant": 0.6666666666666666
                        },
                        "rating": 3.5,
                        "id": "Miso-Vegetable-Noodle-Bowl-Recipezaar",
                        "smallImageUrls": [
                            "http://i.yummly.com/Miso-Vegetable-Noodle-Bowl-Recipezaar-12762.s.png"
                        ],
                        "sourceDisplayName": "Food.com",
                        "totalTimeInSeconds": 1200,
                        "ingredients": [
                            "vegetable broth",
                            "lime",
                            "edamame",
                            "green onion",
                            "snow peas",
                            "fresh cilantro",
                            "carrot",
                            "shiitake mushroom caps",
                            "peeled fresh ginger",
                            "udon",
                            "yellow miso",
                            "napa cabbage",
                            "chili paste",
                            "fresh lime juice",
                            "water",
                            "red bell pepper"
                        ],
                        "recipeName": "Miso Vegetable Noodle Bowl"
                    }
                ]
            });
        // }.bind(this));
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

    addToSelection: function(selected) {
        debugger;
    },

    resultsFormatter: function(res) {
        return {
            data: res.matches.map(function(recipe) {
                return {
                    image: recipe.smallImageUrls[0].replace('s90', 'l90'),
                    name: recipe.recipeName,
                    ingredients: recipe.ingredients,
                    rating: recipe.rating,
                    time: this.recipeTime(recipe.totalTimeInSeconds)
                };
            }.bind(this))
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
                    <div className="recipe-listing caption">
                        <p>{recipe.recipeName}</p>
                        <div className='info valign-wrapper'>
                            <p>{this.recipeTime(recipe.totalTimeInSeconds)}</p>
                            <div className='ratings'>
                                {this.renderRatings(recipe.rating)}
                            </div>
                        </div>
                    </div>
                </div>
            );
        }.bind(this));

        return (
            <div className='card recipes'>
                <div className='card-content full-width'>
                    <div className='carousel carousel-slider'>
                        {carousel_items}
                    </div>
                    <a
                        onClick={this.toggleModal}
                        className="btn-floating btn-large waves-effect waves-light">
                        <i className="material-icons">search</i>
                    </a>
                </div>
                <Modal
                    resultsFormatter={this.resultsFormatter}
                    {...this.state.modal}
                    {...this.props.modal}/>
            </div>
        )
    }
});
