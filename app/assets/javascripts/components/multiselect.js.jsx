var Multiselect = React.createClass({
    mixins: [ModalContainer],
    propTypes: {
        title: React.PropTypes.string,
        button: React.PropTypes.string,
        selection: React.PropTypes.array,
        removeFromSelection: React.PropTypes.func,
        hiddenField: React.PropTypes.string,
        modal: React.PropTypes.object,
        backspaceTarget: React.PropTypes.number
    },

    getDefaultProps: function() {
        return {
            selection: []
        }
    },

    getInitialState: function() {
        return {
            selection: this.props.selection
        };
    },

    handleRemove: function(event) {
        this.props.removeFromSelection(parseInt(event.target.closest('.chip').getAttribute('data-id')));
    },

    render: function() {
        var button, title, remove, modal, image;

        if (this.props.modal) {
            button = <a href={'#' + this.props.modal.id} className='waves effect waves light btn secondary modal-trigger'>
                        {this.props.button}
                     </a>;
            modal = <Modal
                        {...this.props.modal}
                        addToSelection={this.addToSelection}
                        removeFromSelection={this.removeFromSelection}
                        selection={this.state.selection} />
        }

        if (this.props.image) {
            image = <img src={selected.image} />;
        }

        if (this.props.title) {
            title = <h3>{this.props.title}</h3>;
        }

        if (this.props.removeFromSelection) {
            remove = <i className='fa fa-close' onClick={this.handleRemove}/>;
        }

        var selection = this.state.selection.map(function(selected, index) {
            return (
                <div
                    className={this.props.backspaceTarget === index ? 'chip targetted' : 'chip'}
                    data-id={index}
                    key={'selection-' + index} >
                    {image}
                    {selected.name}
                    {remove}
                </div>
            );
        }.bind(this));

        return (
            <div className='multiselect' ref='root'>
                {title}
                <div className='selection-container valign-wrapper'>
                    {selection}
                </div>
                {button}
                {modal}
            </div>
        );
    },

    componentDidMount: function() {
        if (!this.props.removeFromSelection) {
            this.refs.root.addEventListener('selection-updated', function(event) {
                this.setState({ selection: event.detail });
            }.bind(this));
        }
    },

    componentDidUpdate: function(prevProps, prevState) {
        if (this.props.selection !== prevProps.selection) {
            this.setState({ selection: this.props.selection });
        }
        if (this.state.selection !== prevState.selection) {
            if (this.props.hiddenField) {
                document.querySelector(this.props.hiddenField).value = this.state.selection.map(function(selected) {
                    return selected.id
                }).join(',');
            }
        }
    }
});
