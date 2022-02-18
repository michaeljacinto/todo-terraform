const dotenv = require('dotenv');
const assert = require('chai').assert;
dotenv.config();
const request = require('supertest')(`https://${process.env.WEB_URL}/api`);

describe('Test POST methods', () => {

    let good_data = {
        description: 'Best',
        title: 'Test'
    };

    it('Create a new Tutorial - pass', () => {
        return request
            .post('/tutorials')
            .send(good_data)
            .expect(200)
            .then(() => {
            })
    });

    let bad_data = {
        description: 'Test',
        title: ''
    }

    it('Create a new Tutorial - fail', () => {
        return request
            .post('/tutorials')
            .send(bad_data)
            .expect(400)
            .then((res) => {
                assert.include(res.error.text, 'Content can not be empty!')
            })
    });

});

describe('Test GET methods', () => {

    it('Retrieve a single Tutorial with id - pass', () => {
        return request
            .get('/tutorials/1')
            .expect(200)
            .then((res) => {
                assert.isArray(res.body)
                assert.lengthOf(res.body, 1);
            })
    });

    it('Retrieve a single Tutorial with id - fail', () => {
        return request
            .get('/tutorials/55')
            .expect(404)
            .then((res) => {
                assert.include(res.body.message, 'Cannot find Tutorial')
            })
    });

    it('Retrieve all Tutorials', () => {
        return request
            .get('/tutorials')
            .expect(200)
            .then((res) => {
                assert.isArray(res.body)
            })
    });
});

describe('Test PUT methods', () => {

    let good_data = {
        description: 'Some updated description',
        title: 'Some updated title',
        published: true
    }

    it('Update a Tutorial with id - pass', () => {
        return request
            .put('/tutorials/1')
            .send(good_data)
            .expect(200)
            .then((res) => {
                assert.include(res.body.message, 'Tutorial was updated successfully.')
            })
    });

    let bad_data = {
        description: 'Some updated description',
        title: '',
        published: true
    }

    it('Update a Tutorial with id - fail', () => {
        return request
            .put('/tutorials/1')
            .send(bad_data)
            .expect(200)
            .then((res) => {
                assert.include(res.body.message, 'Cannot update Tutorial')
            })
    });

});

describe('Test DELETE methods', () => {

    it('Delete a Tutorial with id - pass', () => {
        return request
            .delete('/tutorials/1')
            .expect(200)
            .then((res) => {
                assert.include(res.body.message, 'Tutorial was deleted successfully!')
            })
    });

    it('Delete a Tutorial with id - fail', () => {
        return request
            .delete('/tutorials/999')
            .expect(200)
            .then((res) => {
                assert.include(res.body.message, 'Cannot delete Tutorial')
            })
    });

    it('Delete all Tutorials - pass', () => {
        return request
            .delete('/tutorials')
            .expect(200)
            .then(() => {
            })
    });
});