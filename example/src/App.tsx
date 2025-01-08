import { useState } from 'react';
import {
  Text,
  View,
  TouchableOpacity,
  TextInput,
  Alert,
  Keyboard,
  Platform,
} from 'react-native';
import styles from './styles';
import { isTextNotEmpty, validateEmail } from './Utils/validation';
import { getSigningKey, isBackupActiveAPI } from 'pv-ew-rn-sdk';

function App() {
  const [result, setResult] = useState('');
  const [email, setEmail] = useState('');

  const _handleValidation = () => {
    Keyboard.dismiss();
    if (!isTextNotEmpty(email)) {
      Alert.alert('Please enter email');
      return;
    } else if (!validateEmail(email)) {
      Alert.alert('Please enter a valid email');
      return;
    } else {
      if (Platform.OS === 'ios') {
        _handleGetSigninKey();
      }
    }
  };

  const _handleGetSigninKey = async () => {
    try {
      const response: any = await getSigningKey(email);
      setResult(response);
    } catch (error) {
      console.error('Failed to get signing key:', error);
      setResult('Error retrieving signing key');
    }
  };

  const _handleAPICall = async () => {
    try {
      const response: any = await isBackupActiveAPI('', '');
      console.log('response:', response);
    } catch (error) {
      console.error('Failed to get signing key:', error);
    }
  };

  return (
    <View style={styles.container}>
      <TextInput
        style={styles.textInput}
        value={email}
        onChangeText={(text) => {
          setEmail(text);
          setResult('');
        }}
        placeholder="Enter your email"
        placeholderTextColor={'gray'}
        keyboardType="email-address"
        returnKeyType="done"
        autoCapitalize="none"
      />
      <TouchableOpacity
        style={styles.button}
        activeOpacity={0.7}
        onPress={() => {
          _handleValidation();
        }}
      >
        <Text style={styles.buttonText}>{'Get Signin Key'}</Text>
      </TouchableOpacity>
      {result && email && (
        <View>
          <Text style={styles.titleText}>{`Input :`}</Text>
          <Text style={styles.text}>{`${email}`}</Text>
          <Text style={[styles.titleText]}>{`OutPut :`}</Text>
          <Text style={styles.text}>{`${result}`}</Text>
        </View>
      )}
      <TouchableOpacity
        style={styles.button}
        activeOpacity={0.7}
        onPress={() => {
          _handleAPICall();
        }}
      >
        <Text style={styles.buttonText}>{'Test API Call'}</Text>
      </TouchableOpacity>
    </View>
  );
}

export default App;
