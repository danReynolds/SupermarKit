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
        let instructionsLink, descriptionContent;
        let description = '';
        const {
            handleAdd,
            resultIndex,
            scrollTarget
        } = this.props;
        const {
            url,
            flavors,
            image,
            name,
            timeInSeconds,
            rating,
            course,
        } = this.props.result;
        var resultClass = 'valign-wrapper recipe-result' + (resultIndex === scrollTarget ? ' target' : '');

        if (url) {
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

        if (flavors && Object.keys(flavors).length) {
            const keyFlavors = Object.keys(flavors)
                .sort((f1, f2) => flavors[f2] - flavors[f1]).slice(0, 2)
            description = `This recipe is mostly ${keyFlavors.join(' and ')}`
        }

        if (course) {
            const courseInfo = course.slice(0, 2).join(' or ')
            if (description) {
                description += ` and it is a good choice if you are looking for ${courseInfo}.`
            } else {
                description += `This recipe is a good choice if you are looking for ${courseInfo}.`
            }
        }

        if (description.length) {
            descriptionContent = (
                <div className='description'>
                    {description}
                </div>
            )
        }

        return (
            <li
                className={resultClass}
                onClick={handleAdd}
                data-index={resultIndex}>
                <img src={image}/>
                <div className='info'>
                    <p>{name}</p>
                    <p>{this.recipeTime(timeInSeconds)}</p>
                    <div className='ratings'>
                        {this.renderRatings(rating)}
                    </div>
                </div>
                {descriptionContent}
                {instructionsLink}
            </li>
        );
    }
})
