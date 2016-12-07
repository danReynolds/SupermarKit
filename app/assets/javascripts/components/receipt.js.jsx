var Receipt = React.createClass({
    mixins: [Pagination],

    propTypes: {
        url: React.PropTypes.string.isRequired,
        checkout_url: React.PropTypes.string.isRequired,
        confirm_url: React.PropTypes.string.isRequired
    },

    getInitialState: function() {
        return {
            matches: null,
            loading: false
        }
    },

    componentDidMount: function() {
        this.setupDropzone();
    },

    componentDidUpdate: function(prevProps, prevState) {
        if (this.state.matches && this.state.matches.length === 0 && !this.state.loading) {
            this.setupDropzone();
        }
    },

    setupDropzone: function() {
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
            this.updatePagination(response.matches.length);
            this.setState({
                matches: response.matches,
                total: response.total,
                loading: false
            });
        }.bind(this));
    },

    renderUpload: function() {
        var uploadContent;
        var uploadText;

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

        if (this.state.matches) {
            uploadText = (
                <p>
                We were not able to find any matches after analyzing your receipt.
                You can try uploading a clearer image and we will try to make our software better.
                </p>
            );
        } else {
            uploadText = (
                <p> Add a picture of your receipt to keep track of exactly what you purchased.
                    We will analyze your receipt and try to match up pricing information and the total cost to your SupermarKit grocery list.
                </p>
            );
        }

        return (
            <div>
                {uploadText}
                {uploadContent}
            </div>

        );
    },

    renderMatches: function() {
        var total = this.state.total;
        var totalContent;

        var sortedItems = this.state.matches.sort(function(item1, item2) {
            return item2.similarity - item1.similarity;
        });

        if (total) {
            totalContent = <div className='total'>Total: ${total}</div>
        }

        var matchesList = this.itemsForPage(sortedItems.map(function(item, index) {
            return (
                <li
                    key={index}
                    className='receipt-item valign-wrapper'>
                    {item.new ? <div className='badge new'>new</div> : null}
                    <p>{item.name}</p>
                    <div className='right-content'>
                        {this.renderConfidence(item)}
                        <div className='badge price'>
                            ${item.price.toFixed(2)}
                        </div>
                    </div>
                </li>
            );
        }.bind(this)));

        return (
            <div>
                <p>
                    We have looked over your receipt and have determined the following prices for matches.
                    These prices will be used to help estimate the cost of item for your next grocery trip.
                </p>
                <ul>
                    {matchesList}
                </ul>
                {this.renderPagination()}
                {totalContent}
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

    confirmReceipt: function() {
        $.ajax({
            method: 'POST',
            data: JSON.stringify({
                grocery: {
                    matches: this.state.matches
                }
            }),
            contentType: 'application/json',
            url: this.props.confirm_url
        }).then(function(response) {
            var uploader_id = response.uploader_id;
            window.location = `${this.props.checkout_url}?uploader_id=${uploader_id}&total=${this.state.total}`
        }.bind(this))
    },

    render: function() {
        var matches = this.state.matches;

        if (this.state.matches) {
            var confirmButton = <a className='btn' onClick={this.confirmReceipt}>Confirm</a>;
        }

        return (
            <div className='card'>
                <div className='card-content'>
                    <h3>Track Receipts</h3>
                    {matches && matches.length ? this.renderMatches() : this.renderUpload()}
                    <a
                        className='btn cancel'
                        href={this.props.checkout_url}>
                        Skip
                    </a>
                    {confirmButton}
                </div>
            </div>
        );
    }
});
