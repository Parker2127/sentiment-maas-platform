from pydantic import BaseModel
try:
    import great_expectations as ge
    from great_expectations.core import ExpectationSuite
    import pandas as pd
    GE_AVAILABLE = True
except ImportError:
    GE_AVAILABLE = False

class UnifiedFeatureSchema(BaseModel):
    text: str

    @classmethod
    def validate_against_training_distribution(cls, text: str):
        if not GE_AVAILABLE:
            # Simple validation without GE
            if not (10 <= len(text) <= 500):
                raise ValueError("Text length must be between 10 and 500 characters.")
            return True
            
        try:
            # Create a DataFrame for Great Expectations validation
            df = pd.DataFrame({"text": [text]})
            df_ge = ge.from_pandas(df)
            
            # Define expectations based on training distribution
            suite = ExpectationSuite("training_distribution")
            df_ge.expect_column_value_lengths_to_be_between("text", min_value=10, max_value=500)
            
            # Run validation
            results = df_ge.validate(expectation_suite=suite)
            if not results.success:
                raise ValueError("Input data does not match training distribution expectations.")
            return True
        except Exception as e:
            # Fallback to simple validation
            if not (10 <= len(text) <= 500):
                raise ValueError("Text length must be between 10 and 500 characters.")
            return True