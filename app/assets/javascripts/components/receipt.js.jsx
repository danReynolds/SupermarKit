var Receipt = React.createClass({
    mixins: [Pagination],

    propTypes: {
        url: React.PropTypes.string.isRequired,
        skip_url: React.PropTypes.string.isRequired
    },

    getInitialState: function() {
        return {
            items: null,
            loading: false
        }
    },

    componentDidMount: function() {
        var dropzone = new Dropzone(
            '#receipt-upload',
            {
                maxFiles: 1
            }
        );

        dropzone.on('sending', function() {
            this.setState({ loading: true });
        }.bind(this));

        dropzone.on('success', function(file, response) {
            this.updatePagination(response.data.matches.length);
            this.setState({
                items: response.data.matches,
                total: response.data.total,
                loading: false
            });
        }.bind(this));
    },

    renderUpload: function() {
        var uploadContent;
        if (this.state.loading) {
            uploadContent = <Loader/>
        } else {
            uploadContent = (
                <form
                    id='receipt-upload'
                    action={this.props.url}
                    className='dropzone'>
                    <div className='dz-message'>
                        <p>Upload Receipt</p>
                        <i className='fa fa-plus-circle'/>
                    </div>
                    <input
                        name='authenticity_token'
                        type='hidden'
                        value={this.props.token} />
                    <div className='fallback'>
                        <input name='file' type='file'/>
                    </div>
                </form>
            );
        }

        return (
            <div>
                <p> Add a picture of your receipt to keep track of exactly what you purchased.
                    We will analyze your receipt and try to match up pricing information and the total cost to your SupermarKit grocery list.
                </p>
                {uploadContent}
            </div>

        );
    },

    renderItems: function() {
        var itemList = this.itemsForPage(this.state.items.map(function(item, index) {
            return (
                <li
                    key={index}
                    className='receipt-item valign-wrapper'>
                    <p>{item.name}</p>
                    <div className='right-content'>
                        {this.renderConfidence(item)}
                        <div className='price'>
                            ${item.price}
                        </div>
                    </div>
                </li>
            );
        }.bind(this)));

        return (
            <div>
                <p>
                    We have looked over your receipt and have determined the following prices for items.
                    These prices will be used to help estimate the cost of item for your next grocery trip.
                </p>
                <ul>
                    {itemList}
                </ul>
                {this.renderPagination()}
            </div>
        );
    },

    renderConfidence: function(item) {
        var ratingContent = [];
        var ratingModifier = 0.2;
        var ratingClass;

        if (item.similarity >= 0.8) {
            ratingClass = 'strong';
        } else if (item.similarity >= 0.6) {
            ratingClass = 'moderate';
        } else {
            ratingClass = 'weak';
        }

        _(Math.floor(item.similarity / ratingModifier)).times(function(index) {
            ratingContent.push(
                <i
                    key={index}
                    className='fa fa-check'/>
            );
        })

        return (
            <div className={'confidence ' + ratingClass}>
                {ratingContent}
            </div>
        );
    },

    render: function() {
        if (this.state.items) {
            var confirmButton = <a className='btn' href={this.props.confirm_url}>Confirm</a>;
        }

        return (
            <div className='card'>
                <div className='card-content'>
                    <h3>Track Receipts</h3>
                    {this.state.items ? this.renderItems() : this.renderUpload()}
                    <a
                        className='btn cancel'
                        href={this.props.skip_url}>
                        Skip
                    </a>
                    {confirmButton}
                </div>
            </div>
        );
    }
});
