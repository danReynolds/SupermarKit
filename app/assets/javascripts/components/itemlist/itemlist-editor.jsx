class ItemListEditor extends React.Component {
    static propTypes = {
        price: React.PropTypes.any,
        estimatedPrice: React.PropTypes.any,
        handleItemUpdate: React.PropTypes.func,
        quantity: React.PropTypes.number,
        id: React.PropTypes.number,
        units: React.PropTypes.string,
        getSelectedIndex: React.PropTypes.func,
        unitTypes: React.PropTypes.object
    }

    constructor(props)  {
        super(props);

        this.state = this.updatedFields(props);
        this.handleItemFieldChange = this.handleItemFieldChange.bind(this);
        this.handleItemUpdate = this.handleItemUpdate.bind(this);
        this.initializeAutocomplete = this.initializeAutocomplete.bind(this);
    }

    componentWillReceiveProps(nextProps) {
        const { price, quantity, units, estimatedPrice } = nextProps;
        this.setState({
            price: price || estimatedPrice,
            quantity: quantity,
            units: units
        });
    }

    componentDidMount() {
        this.initializeAutocomplete();
    }

    handleItemUpdate() {
        const { handleItemUpdate, id } = this.props;
        handleItemUpdate(id, this.state)
    }

    handleItemFieldChange(e) {
        const { getSelectedIndex } = this.props;
        const { price } = this.state;

        var index = getSelectedIndex(e);
        var field = e.target.getAttribute('data-field');
        var target = e.target;
        var value =  target.value;

        if (target.type === 'number') {
            if (value !== "") {
                value = parseFloat(value);
                if (!Number.isFinite(value)) {
                    value = price;
                }
            }
        }

        this.setState({ [field]: value });
    }

    updatedFields(props) {
        const { price, quantity, units } = props;
        return { price: price, quantity: quantity, units: units };
    }

    initializeAutocomplete() {
        const { unitTypes } = this.props;
        const input = $(this.autocomplete);
        input.autocomplete({ data: unitTypes });
        input.on('change', this.handleItemFieldChange);
    }

    render() {
        const { handleItemUpdate, id, price: oldPrice } = this.props;
        const { price: newPrice, quantity, units } = this.state;
        const quantityId = `quantity-${id}`;
        const priceId = `price-${id}`;
        const unitsId = `units-${id}`;

        return (
            <div className='collapsible-body'>
                <div className="valign-wrapper">
                    <div className="col l3 s3">
                        <label htmlFor={quantityId}>Quantity</label>
                        <input
                            onChange={this.handleItemFieldChange}
                            id={quantityId}
                            data-field="quantity"
                            type="number"
                            step="any"
                            value={quantity} />
                    </div>
                    <div className="col s3">
                        <label htmlFor={priceId}>{oldPrice ? 'Price' : 'Estimated Price'}</label>
                        <input
                            onChange={this.handleItemFieldChange}
                            id={priceId}
                            type="number"
                            data-field="price"
                            step="any"
                            value={newPrice} />
                    </div>
                    <div className="col l3 s3">
                        <label htmlFor={unitsId}>Units</label>
                        <input
                            ref={(input) => { this.autocomplete = input; }}
                            className='autocomplete'
                            onChange={this.handleItemFieldChange}
                            id={unitsId}
                            type="text"
                            data-field="units"
                            value={units || ''} />
                    </div>
                    <a
                        data-no-turbolink
                        className='btn'
                        onClick={this.handleItemUpdate}>
                        Update
                    </a>
                </div>
            </div>
        );
    }
};
