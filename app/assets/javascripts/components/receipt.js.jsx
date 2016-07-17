var Receipt = React.createClass({
    propTypes: {
        url: React.PropTypes.string.isRequired,
        skip_url: React.PropTypes.string.isRequired
    },

    componentDidMount: function() {
        var dropzone = new Dropzone(
            '#receipt-upload',
            {
                maxFiles: 1
            }
        );
        dropzone.on('addedfile', function() {
            console.log("added");
        });
    },

    render: function() {
        return (
            <div className='card'>
                <div className='card-content'>
                    <h3>Track Receipts</h3>
                    <p> Add a picture of your receipt to keep track of exactly what you purchased.
                        We will analyze your receipt and match up pricing information and the total cost to your SupermarKit grocery list.
                    </p>
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
                    <a
                        className='btn'
                        href={this.props.skip_url}>
                        Skip
                    </a>
                </div>
            </div>
        );
    }
});
