var RecipeResult = React.createClass({
    mixins: [RecipeHelper],

    propTypes: {
        resultIndex: React.PropTypes.number.isRequired,
        handleAdd: React.PropTypes.func.isRequired,
        result: React.PropTypes.object.isRequired,
        scrollTarget: React.PropTypes.number.isRequired
    },

    render: function() {
        var resultClass = 'valign-wrapper recipe-result' + (this.props.resultIndex == this.props.scrollTarget ? ' target' : "");
        return (
            <li
                className={resultClass}
                onClick={this.props.handleAdd}
                data-index={this.props.resultIndex}>
                <div className='valign-wrapper'>
                    <img src={this.props.result.image}/>
                    <div className='info'>
                        <p>{this.props.result.name}</p>
                        <p>{this.props.result.time}</p>
                        <div className='ratings'>
                            {this.renderRatings(this.props.result.rating)}
                        </div>
                    </div>
                </div>
            </li>
        );
    }
})
