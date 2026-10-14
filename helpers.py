class DotDict(dict):
    """
    A dictionary subclass that enables dot notation for accessing, 
    setting, and deleting keys recursively.
    """
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Recursively convert any nested dict inputs into DotDicts
        for key, value in self.items():
            self[key] = self._convert(value)

    def __getattr__(self, key):
        try:
            return self[key]
        except KeyError:
            raise AttributeError(f"'DotDict' object has no attribute '{key}'")

    def __setattr__(self, key, value):
        self[key] = self._convert(value)

    def __delattr__(self, key):
        try:
            del self[key]
        except KeyError:
            raise AttributeError(f"'DotDict' object has no attribute '{key}'")

    def _convert(self, value):
        """Recursively process values to handle nested dictionaries and lists."""
        if isinstance(value, dict) and not isinstance(value, DotDict):
            return DotDict(value)
        elif isinstance(value, list):
            return [self._convert(item) for item in value]
        return value
