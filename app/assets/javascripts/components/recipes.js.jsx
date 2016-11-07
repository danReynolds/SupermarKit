var Recipes = React.createClass({
    mixins: [ModalContainer, RecipeHelper],

    propTypes: {
        updateRecipes: React.PropTypes.func
    },

    getInitialState: function() {
        return {
            suggestedRecipes: []
        }
    },

    getSuggestedRecipes: function() {
        this.toggleLoading();
        $.getJSON(this.props.modal.queryUrl + this.props.modal.category, function(response) {
            this.setState(
                React.addons.update(
                    this.state,
                    {
                        suggestedRecipes: { $set: response.matches },
                        modal: {
                            loading: { $set: false }
                        }
                    }
                ),
                function() {
                    $(document).ready(function() {
                        $('.carousel').carousel({
                            full_width: true,
                            time_constant: 100,
                            indicators: true,
                        });
                    });
                }
            );
        }.bind(this));
    },

    componentDidMount: function() {
        if (!this.state.modal.selection.length) {
            this.getSuggestedRecipes();
        }
    },

    componentDidUpdate: function(prevProps, prevState) {
        if (!this.state.modal.open && prevState.modal.open && !this.state.modal.selection.length) {
            if (this.state.suggestedRecipes.length) {
                $('.carousel').carousel({
                    full_width: true,
                    time_constant: 100,
                    indicators: true,
                });
            } else {
                this.getSuggestedRecipes();
            }
        }
    },

    resultsFormatter: function(res) {
        return {
            data: res.matches.map(function(recipe) {
                return {
                    image: recipe.imageUrlsBySize[90].replace('s90', 'l90'),
                    name: recipe.recipeName,
                    ingredients: recipe.ingredients,
                    rating: recipe.rating,
                    timeInSeconds: recipe.totalTimeInSeconds,
                    externalId: recipe.id,
                    flavors: recipe.flavors,
                    course: recipe.attributes.course,
                };
            }.bind(this))
        }
    },

    handleClick: function(e) {
        var recipe = this.state.suggestedRecipes[parseInt($(e.target).closest('.carousel-item').attr('data-key'))];

        this.setState({
            modal: React.addons.update(
                this.state.modal,
                {
                    open: {$set: true},
                    loading: {$set: true},
                    openWithSelection: {
                        $set: this.resultsFormatter({matches: [recipe]}).data
                    }
                }
            )
        });
    },

    handleSave: function(modalSelection) {
        var _this = this;
        var additionalRecipeData = {};
        var requests = modalSelection.reduce(function(acc, selected) {
            if (!selected.url) {
                acc.push(
                    $.getJSON(this.props.modal.recipeUrl.replace('@externalId', selected.externalId))
                );
            }
            return acc;
        }.bind(this), []);

        $.when.apply($, requests).then(function(response) {
            if (requests.length === 1) {
                arguments = [arguments];
            }
            $.each(arguments, function(index, response) {
                recipe = response[0];
                additionalRecipeData[recipe.id] = {
                    url: recipe.source.sourceRecipeUrl,
                    ingredientLines: recipe.ingredientLines
                };
            });

            $.ajax({
                method: 'PATCH',
                data: JSON.stringify({
                    grocery: {
                        recipes: modalSelection.map(function(selected) {
                            if (selected.url) {
                                return {
                                    external_id: selected.externalId
                                }
                            } else {
                                return {
                                    image_url: selected.image,
                                    name: selected.name,
                                    rating: selected.rating,
                                    timeInSeconds: selected.timeInSeconds,
                                    external_id: selected.externalId,
                                    items: selected.ingredients,
                                    ...additionalRecipeData[recipe.id]
                                };
                            }
                        })
                    }
                }),
                contentType: 'application/json',
                url: _this.props.modal.updateUrl
            }).done(function(response) {
                _this.setState({
                    modal: React.addons.update(
                        _this.state.modal,
                        {
                            selection: {
                                $set: response.data
                            },
                            openWithSelection: {
                                $set: []
                            }
                        }
                    )
                }, function() {
                    _this.props.updateRecipes(_this.state.modal.selection);
                    _this.toggleModalAndLoading();
                });
            });
        });
    },

    renderSuggestedRecipes: function() {
        var carousel_items = this.state.suggestedRecipes.map(function(recipe, index) {
            return (
                <div
                    onClick={this.handleClick}
                    key={'carousel-item-' + index}
                    data-key={index}
                    className='carousel-item'>
                    <a href="#">
                        <img src={recipe.imageUrlsBySize[90].replace('s90', 'l90')} />
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
            <div>
                {this.renderHeader()}
                <div className='carousel carousel-slider'>
                    {carousel_items}
                </div>
            </div>
        );
    },

    renderHeader: function() {
        return (
            <div className='card-header'>
                <h3>{this.state.modal.selection.length ? this.props.yourRecipeHeader : this.props.suggestedReciperHeader}</h3>
                <i className='fa fa-bookmark-o'/>
            </div>
        );
    },

    renderRecipes: function() {
        var recipes = this.state.modal.selection.map(function(selected, index) {
            return (
                <RecipeResult
                    key={'recipe-' + index}
                    resultIndex={index}
                    result={selected} />
            );
        });

        return (
            <div>
                {this.renderHeader()}
                <ul>
                    {recipes}
                </ul>
            </div>
        );
    },

    render: function() {
        var content;
        if (this.state.modal.loading) {
            content = <Loader />
        } else if (this.state.modal.selection.length) {
            content = this.renderRecipes();
        } else {
            content = this.renderSuggestedRecipes();
        }

        return (
            <div className='card recipes'>
                <div className='card-content full-width dark'>
                    {content}
                    <a
                        onClick={this.toggleModalAndLoading}
                        className="btn-floating">
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
