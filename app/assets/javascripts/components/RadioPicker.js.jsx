const RadioPicker = ({ selectedOption, options, onChange }) => {
    handleChange = (e) => {
        onChange(parseInt(e.target.id));
    }

    renderOptions = () => {
        return options.map(option => {
            const { id, image, name } = option;
            return (
                <p key={id}>
                    <input
                        onChange={handleChange}
                        type='radio'
                        id={id}
                        checked={id === selectedOption}
                    />
                    <label htmlFor={id}>{name}</label>
                </p>
            );
        })
    }

    return (
        <div className='radio-picker'>
            {this.renderOptions()}
        </div>
    );
};

RadioPicker.propTypes = {
    selectedOption: React.PropTypes.number,
    options: React.PropTypes.array,
    onChange: React.PropTypes.func,
};
