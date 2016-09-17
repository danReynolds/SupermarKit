var RecipeResult = React.createClass({
    mixins: [RecipeHelper],

    propTypes: {
        resultIndex: React.PropTypes.number.isRequired,
        handleAdd: React.PropTypes.func,
        result: React.PropTypes.object.isRequired,
        scrollTarget: React.PropTypes.number
    },

    handleClick: function(e) {
        e.stopPropagation();
    },

    render: function() {
        var resultClass = 'valign-wrapper recipe-result' + (this.props.resultIndex === this.props.scrollTarget ? ' target' : "");
        var instructionsLink;

        if (this.props.result.url) {
            instructionsLink = (
                <a
                    className='btn dark'
                    onClick={this.handleClick}
                    target='_blank'
                    rel='noopener'
                    href={this.props.result.url}>
                    View
                </a>
            );
        }
        return (
            <li
                className={resultClass}
                onClick={this.props.handleAdd}
                data-index={this.props.resultIndex}>
                <img src={this.props.result.image}/>
                <div className='info'>
                    <p>{this.props.result.name}</p>
                    <p>{this.recipeTime(this.props.result.timeInSeconds)}</p>
                    <div className='ratings'>
                        {this.renderRatings(this.props.result.rating)}
                    </div>
                </div>
                {instructionsLink}
            </li>
        );
    }
})
